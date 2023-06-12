/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowGenomeassembly.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.input, params.fastq, params.db ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.fastq) { ch_fastq = file(params.fastq) } else { exit 1, 'Input reads in fastq format not specified!' }
if (params.db) { ch_db = file(params.db) } else { exit 1, 'Centrifuge database not specified!' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//ch_multiqc_config          = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
//ch_multiqc_custom_config   = params.multiqc_config ? Channel.fromPath( params.multiqc_config, checkIfExists: true ) : Channel.empty()
//ch_multiqc_logo            = params.multiqc_logo   ? Channel.fromPath( params.multiqc_logo, checkIfExists: true ) : Channel.empty()
//ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules

// MODULES
//include { CENTRIFUGE_FILTER } from '../modules/local/centrifuge/filter/main'
// SUBWORKFLOWS
include { INPUT_CHECK } from '../subworkflows/local/input_check'
//include { READ_QC } from '../subworkflows/local/read_qc'
//include { ASSEMBLY } from '../subworkflows/local/assembly'
//include { QC_1 } from '../subworkflows/local/qc_1'
//include { POLISH } from '../subworkflows/local/polish'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CENTRIFUGE_CENTRIFUGE                      } from '../modules/nf-core/centrifuge/centrifuge/main'
include { CENTRIFUGE_KREPORT                      } from '../modules/nf-core/centrifuge/kreport/main'
include { NANOPLOT                      } from '../modules/nf-core/nanoplot/main'
//include { FLYE                      } from '../modules/nf-core/flye/main'
//include { MINIMAP2_ALIGN                      } from '../modules/nf-core/minimap2/align/main'
//include { MINIMAP2_INDEX                      } from '../modules/nf-core/minimap2/index/main'
//include { BUSCO                      } from '../modules/nf-core/busco/main'
//include { QUAST                      } from '../modules/nf-core/quast/main'
//include { MEDAKA                      } from '../modules/nf-core/medaka/main'                                
//include { FASTQC                      } from '../modules/nf-core/fastqc/main'
//include { MULTIQC                     } from '../modules/nf-core/multiqc/main'
//include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Info required for completion email and summary
//def multiqc_report = []

workflow GENOMEASSEMBLY {

    ch_versions = Channel.empty()

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    ch_data = INPUT_CHECK ( ch_input )
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)

    //READ_QC (
   //     ch_data.reads, params.fastq, params.db
    //)
   // ch_versions = ch_versions.mix(READ_QC.out.versions)

    //ASSEMBLY (
    //    ch_data.reads, ch_fastq_out
   // )
   // ch_versions = ch_versions.mix(ASSEMBLY.out.versions)

   // QC_1 (
   //     FLYE.out.fasta
    //)
   // ch_versions = ch_versions.mix(QC_1.out.versions)

    //POLISH (
    //   ch_data.reads, FLYE.out.fasta
   // )


    //
    // MODULE: Run FastQC
    //
   // FASTQC (
   //     INPUT_CHECK.out.reads
   // )
   // ch_versions = ch_versions.mix(FASTQC.out.versions.first())

   // CUSTOM_DUMPSOFTWAREVERSIONS (
   //     ch_versions.unique().collectFile(name: 'collated_versions.yml')
   // )

    //
    // MODULE: MultiQC
    //
   // workflow_summary    = WorkflowGenomeassembly.paramsSummaryMultiqc(workflow, summary_params)
   // ch_workflow_summary = Channel.value(workflow_summary)

    //methods_description    = WorkflowGenomeassembly.methodsDescriptionText(workflow, ch_multiqc_custom_methods_description)
    //ch_methods_description = Channel.value(methods_description)

    //ch_multiqc_files = Channel.empty()
    //ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    //ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml'))
   // ch_multiqc_files = ch_multiqc_files.mix(CUSTOM_DUMPSOFTWAREVERSIONS.out.mqc_yml.collect())
   // ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]}.ifEmpty([]))

 //   MULTIQC (
 //       ch_multiqc_files.collect(),
  //      ch_multiqc_config.toList(),
 //       ch_multiqc_custom_config.toList(),
  //      ch_multiqc_logo.toList()
 //  )
 //   multiqc_report = MULTIQC.out.report.toList()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//workflow.onComplete {
 //   if (params.email || params.email_on_fail) {
 //      NfcoreTemplate.email(workflow, params, summary_params, projectDir, log, multiqc_report)
  //  }
 //   NfcoreTemplate.summary(workflow, params, log)
 //   if (params.hook_url) {
 //       NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
  //  }
//}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
