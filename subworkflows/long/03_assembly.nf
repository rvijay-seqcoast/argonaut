//include { GUNZIP } from '../../modules/nf-core/gunzip/main'
include { NANOPLOT } from '../../modules/nf-core/nanoplot/main'
include { TOTAL_BASES_LR } from '../../modules/local/total_bases_lr'
include { COVERAGE_LR } from '../../modules/local/coverage_lr'
include { FLYE } from '../../modules/nf-core/flye/main' 
include { MASURCA } from '../../modules/local/masurca'
include { CANU } from '../../modules/nf-core/canu/main' 
include { HIFIASM } from '../../modules/nf-core/hifiasm/main' 


workflow ASSEMBLY {

    take:
        longreads   // channel: [ val(meta), [ decontaminated and/or length filtered fastq ] ]
        shortreads
        genome_size_est
        genome_size_est_long

    main:
    ch_versions = Channel.empty() 

        //makes sure long read input is filtered reads
        NANOPLOT (longreads)

        TOTAL_BASES_LR(NANOPLOT.out.txt)
        COVERAGE_LR(genome_size_est_long, TOTAL_BASES_LR.out.total_bases)

        assemblies = Channel.empty() 

        //if statement to run assembly and create channels for each resulting assembly
        if ( params.flye == true ) {
            println "assembling long reads with flye!"
            FLYE(longreads, params.flye_mode, genome_size_est)
            f_assembly      = FLYE.out.fasta          
        } else {
            f_assembly = Channel.empty() 
        }

        if ( params.canu == true ) {
            println "assembling long reads with canu!"
            CANU(longreads, params.canu_mode, genome_size_est)
            c_assembly      = CANU.out.assembly   
        } else {
            c_assembly = Channel.empty() 
        }

        if ( params.masurca == true && params.shortread == true) {
            println "hybrid assembly with maSuRCA!"
            MASURCA(longreads, shortreads)
            m_assembly    = MASURCA.out.fasta
        } else {
            m_assembly = Channel.empty() 
        }

        if (params.hifiasm ==true){
            HIFIASM(longreads, [],[],[],[])
            println "assembling long reads with hifiasm!"
            h_assembly    = HIFIASM.out.assembly_fasta

        } else {
            h_assembly = Channel.empty() 
        }

        if ( params.ex_assembly == true ) {
            println "inputting existing assembly!"
            ex = Channel.fromPath(params.existing_assembly)
        } else {
            ex_assembly = Channel.empty() 
        }

        assemblies
            .concat(f_assembly, c_assembly, m_assembly, h_assembly, ex_assembly)
            .collect()
            .flatten()
            .map { file -> tuple([id: file.baseName], file)  }
            .set { all_assemblies }

    emit:
        all_assemblies  
        longreads   
        nanoplot_filtered_out   = NANOPLOT.out.html
        f_assembly
        
    versions = ch_versions                     // channel: [ versions.yml ]
}
