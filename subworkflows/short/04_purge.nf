include { REDUNDANS_P } from '../../modules/local/redundans_purge'  

workflow PURGE2 {

    take:
        assembly
        shortreads
        
    main:

    ch_versions = Channel.empty() 

        REDUNDANS_P (assembly, shortreads)

        purged_sr_assembly      = REDUNDANS_P.out.assembly_fasta 

            purged_sr_assembly
                .map { file -> tuple(id: file.baseName, file)  }
                .set { purged_assembly }

        purged_assembly.view()

    emit:
        purged_assembly
        purged_sr_assembly
                 
        
    versions = ch_versions                     // channel: [ versions.yml ]
}
