#!/usr/bin/env nextflow
def helpMessage() {
	log.info"""
	========================================================================================
        GenomeAssembly- a computational tool for de novo eukaryotic genome assembly
	========================================================================================
 	
	Usage:
	nextflow run nf-core-genomeassembly -params-file params.yaml
	
	Required arguments:
		--input				 Path to samplesheet with input (*.csv)
		--fastq					 Path to SRA accession list (*.fastq)
		--db				 Relevant Centrifuge database as source of contaminant screening
		--busco_lineages_path					 Relevant lineage for BUSCO evaluation (ex. )

	Recommended arguments:
		--outdir				 Path to the output directory (default: OUTDIR)
		--max_memory          			 Maximum memory allocated
	    	--max_cpus              	         Maximum cpus allocated
    		--max_time                               Maximum time allocated

    Optional arguments:    

   """.stripIndent()
}

params.help = false
if (params.help){
    helpMessage()
    exit 0
}


nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

params.fastq = WorkflowMain.getGenomeAttribute(params, 'fastq')
params.db = WorkflowMain.getGenomeAttribute(params, 'db')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE & PRINT PARAMETER SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

WorkflowMain.initialise(workflow, params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { LONGREADASSEMBLY } from './workflows/longreadassembly'
//include { SHORTREADASSEMBLY } from './workflows/shortreadassembly

//
// WORKFLOW: Run main genomeassembly analysis pipeline
//
workflow GENOMEASSEMBLY {
    LONGREADASSEMBLY ()
}
//add conditional statement to allow for short read / hybrid assembly
//need second short read workflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {
    GENOMEASSEMBLY ()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
