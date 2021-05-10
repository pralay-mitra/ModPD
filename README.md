# ModPD
########### README FILE #################

--------------------------------------------------
		Program Input Preparation
--------------------------------------------------

1. Keep the input PDB file in the folder Modular_Protein_Design/INPUT/pdb/.
2. Prepare the Param.txt file in the appropriate format (Refer the example_Param.txt).

---------------------------------------------------
                Program Execution
---------------------------------------------------

Inside the Modular_protein_Design folder, execute the following


perl modular_prot_des.pl PDBID OUTDIR

---> PDBID: PDBID of the input protein.

---> OUTDIR: absolute path to the directory where the output data must be stored

e.g. perl modular_prot_des.pl 1TUKA /home/abantika/Modular_Protein_Design/output

The INPUT folder contains folders viz. evoref, locks, module, param, pdb, phyref, profile, randseq which will be populated during program 
execution (except pdb folder).


OUTPUT

- file OUTDIR/OUTPUT_TAG/PDBID/clu/designed.txt contains the designed sequences for protein PDBID.

example_INPUT and example_output folder are given for reference.

To run the Modular_Protein_Design program, we need the following.

1. SCWRL program is used for prediction of protein side-chain conformations.
G. G. Krivov, M. V. Shapovalov, and R. L. Dunbrack, Jr. Improved prediction of protein side-chain conformations with SCWRL4. Proteins (2009). 

2. FoldX is an empirical force field used to assess the effect of mutations on the stability, and interaction of proteins and nucleic acids.
 J. Schymkowitz, J. Borg, F. Stricher, R. Nys, F. Rousseau, and L. Serrano. The foldx webserver: an online force field. Nucleic Acids Research (2005)

3. DSSP- Given a 3-D protein structure, DSSP assigns secondary structures to the amino acids.
W. Kabsch, C. Sander. Dictionary of protein secondary structure: pattern recognition of hydrogen-bonded and geometrical features. Biopolymers. (1983)

4. Protein Peeling is used to split a protein 3-D structure into protein units.
 J.C.Gelly and A. G. de Brevern, Protein Peeling 3D: new tools for analyzing protein structures. Bioinformatics (2010).

5. TMAlign is used to compare two input protein 3-D structures.
 Y. Zhang and J. Skolnick, Tm-align: a protein structure alignment algorithm based onthe tm-score, Nucleic Acids Research (2005).

6. GNU C Library 2.14 (https://ftp.gnu.org/gnu/libc/)

7. PDB library from ITASSER-suite which contains non-redundant protein structures from Protein DataBank (https://zhanglab.ccmb.med.umich.edu/library/PDB.tar.bz2).

