#!/usr/bin/perl
################################################################################
#                                                                              #
#                                   pdrun.pl                                   #
#                                                                              #
# Runs the protein design algorithm for a protein. 	                       #
#                                                                              #
# ARGUMENT:                                                                    #
#  ---> PDBID: PDBID of the input protein.			               #
#                                                                              #
# ---> OUTDIR: absolute path to the directory where the output data must be    #
#              stored.                                                         #
#                                                                              #
# OUTPUT:                                                                      #
# - file OUTDIR/$EXPTAG/PDBID/clu/designed.txt contains the designed sequences #
#   for protein PDBID.          					       #
#                                                                              #
# NOTES:                                                                       #
#  - the i-th designed sequence in designed.txt represents the i-th cluster    #
#    tag (i=0,...,N-1, where N is the number of cluster tags [Bazzoli et al.,  #
#    J. Mol. Biol. (2011). 407, 764-776]). The i-th sequence starts at the     #
#    start of the i-th line and is immediately followed by a line terminator.  #
#    The file terminates after the last sequence's line terminator.            #
#                                                                              #
################################################################################

$PERL = '/usr/bin/perl'; 		

@PARAM = `cat Param.txt`;

for($i=0; $i<@PARAM; $i++) {
  
  chomp($par = $PARAM[$i]);
  @arr=split(":",$par);
  if($arr[0] eq "SCWRLPATH"){
	$SCWRLPATH=$arr[1];	# SCWRL directory
  }
  elsif($arr[0] eq "FOLDXPATH"){
	$FOLDXPATH=$arr[1];	# FOLDX directory
  }
  elsif($arr[0] eq "DSSPEXE"){
	$DSSPEXE=$arr[1];	# path to DSSP
  }
  elsif($arr[0] eq "PPEELEXE"){
	$PPEELEXE=$arr[1];	#path to protein peeling
  }
  elsif($arr[0] eq "PDBPATH"){
	$PDBLIB=$arr[1];	#path to PDBLIB
  }	
  elsif($arr[0] eq "USERID"){
	$user=$arr[1];		#user
  }
  elsif($arr[0] eq "OUTPUT_TAG"){
	$EXPTAG=$arr[1];	# tag identifying the experiment (must not start with "base")
  }
  elsif($arr[0] eq "TMALIGNEXE"){
	$TMALIGNEXE=$arr[1];	#path to TMALIGN
  }
}

$NRUNS = 10; 		# Number of Monte Carlo trajectories			
$NSTEPS = 30000;	# Number of steps per trajectory
$LOCSTEPS = 200;	# Number of local steps after which the conformations are swapped

$PDBID = $ARGV[0];
$OUTDIR = $ARGV[1];

$INSTDIR=`pwd`;
chomp($INSTDIR);

print "INSTDIR:$INSTDIR\n";


# check that the arguments are valid

if(!(-d $OUTDIR)) {
  print "ERROR: please specify an existing output directory.\n";
  exit;
}

$sfx = substr($OUTDIR, -1);
if($sfx eq '/') {
  print "ERROR: please remove the final '/' from the directory name.\n";
  exit;
}

$pfx = substr($OUTDIR, 0, 1);
if($pfx ne '/') {
  print "ERROR: the path to the output directory must be absolute.\n";
  exit;
}



########################################################
#                                                      #
# prepare programs specific to the present experiment  #
#                                                      #
########################################################

 $LIBDIR = "$OUTDIR/$EXPTAG/lib";
 `mkdir -p $LIBDIR`;

 `cp -r $INSTDIR/lib/* $LIBDIR`;
 chdir "$LIBDIR";

 mkdir "INPUT";
 mkdir "INPUT/profile";
 mkdir "INPUT/evoref";
 mkdir "INPUT/phyref";
 mkdir "INPUT/pdb";
 mkdir 'INPUT/seq';
 mkdir "INPUT/param";
 mkdir "INPUT/module";
 mkdir 'INPUT/aadis';
 `mv evo_nrg/random.txt evo_nrg/n_tv.txt INPUT/aadis`;
 mkdir "INPUT/subs";
 `mv evo_nrg/blosum-62.txt INPUT/subs`;

 `cp -f evo_nrg/*_weigh $LIBDIR/`;
 `cp -f evo_nrg/S?prop.txt $LIBDIR/`;
 `cp -f evo_nrg/ann_fea $LIBDIR/`;
 `cp -f evo_nrg/*.net $LIBDIR/`;
 `cp -f evo_nrg/test* $LIBDIR/`;

#Dividing the protein into modules 

 $PU_file = "$INSTDIR/INPUT/module/$PDBID.mtx";
 if(!(-s $PU_file)) {
 	`$LIBDIR/protein_div $PDBID $LIBDIR $INSTDIR $DSSPEXE $PPEELEXE`;
 }

 `cp $PU_file $LIBDIR/INPUT/module/$PDBID.mtx`;
 $NUMPU=`wc -l $INSTDIR/INPUT/module/$PDBID.mtx`;

########################################################
#                                                      #
# do protein design for the input protein	       #
#                                                      #
########################################################


  $HPDIR = "$OUTDIR/$EXPTAG/$PDBID";
  `mkdir -p $HPDIR`;
  chdir $HPDIR;

  $LPDIR = "/tmp/$user/base-$EXPTAG-$PDBID";
  $SCRFIL = "$PDBID-pdrun.pl"; 
  open(SCRIPT, ">$SCRFIL");
  print SCRIPT "#!/usr/bin/perl\n\n";
  print SCRIPT "`mkdir -p $LPDIR`;\n";
  print SCRIPT "chdir '$LPDIR';\n";
  print SCRIPT "`$LIBDIR/design_single_protein $SCWRLPATH $FOLDXPATH $DSSPEXE $PDBLIB $user $EXPTAG $TMALIGNEXE $NRUNS $NSTEPS $LOCSTEPS $PDBID $OUTDIR $INSTDIR >runout.txt 2>runerr.txt`;\n";
  print SCRIPT "`cp runout.txt runerr.txt $HPDIR`;\n";
  print SCRIPT "`sync`;\n";
  print SCRIPT "`sync`;\n";
  print SCRIPT "sleep 10;\n";
  print SCRIPT "`rm *`;\n";
  print SCRIPT "`rmdir $LPDIR`;\n";
  #print SCRIPT "chdir '$LIBDIR';\n";
  #print SCRIPT "`rm *`;\n";
  print SCRIPT "sleep 10;\n";
  print SCRIPT "`rm -rf $LIBDIR`;\n";
  close(SCRIPT);
 
  $core=($NUMPU*$NRUNS)+1;

  $OPTIONS = "-J pd-$EXPTAG-$PDBID -n $core -q med -o $HPDIR/pbsout.txt -e $HPDIR/pbserr.txt -W 600:00";
  `bsub $OPTIONS $PERL $PDBID-pdrun.pl`;
  sleep 2;

