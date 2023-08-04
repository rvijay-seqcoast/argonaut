include { CENTRIFUGE_CENTRIFUGE } from '../../modules/nf-core/centrifuge/centrifuge/main'
include { CENTRIFUGE_KREPORT } from '../../modules/nf-core/centrifuge/kreport/main'
include { NANOPLOT } from '../../modules/nf-core/nanoplot/main'
include { KMER_FREQ } from '../../modules/local/kmerfreq'
include { GCE } from '../../modules/local/gce'
include { EXTRACT } from '../../modules/local/extract_genome_size'
include { RECENTRIFUGE_C } from '../../modules/local/recentrifuge/centrifuge'
include { SEQKIT_GREP } from '../../modules/local/seqkit/grep/main'

workflow READ_QC {

    take:
  
        reads  // channel: [ val(meta), [ reads ] ]
        ch_db 
           
    main:
    
    ch_versions = Channel.empty()

        reads.view()

        NANOPLOT(reads)

        KMER_FREQ(reads)

        GCE(KMER_FREQ.out.kmerstat, KMER_FREQ.out.kmernum)

        EXTRACT(GCE.out.gce2log)

        // if a centrifuge database is provided, run centrifuge and filter out all classified results
        if( ch_db ){
             CENTRIFUGE_CENTRIFUGE        ( reads, ch_db, params.save_unaligned, params.save_aligned, params.sam_format )
             CENTRIFUGE_KREPORT           ( CENTRIFUGE_CENTRIFUGE.out.results, ch_db )
        }

        SEQKIT_GREP(CENTRIFUGE_CENTRIFUGE.out.results, reads)

        RECENTRIFUGE_C(CENTRIFUGE_CENTRIFUGE.out.results, params.rcf_db)

        fastq_filt           = SEQKIT_GREP.out.filter

        fastq_filt
            .map { file -> tuple([id:file.baseName, single_end:true], file)  }
            .set { filtered_fastq }
        filtered_fastq.view()

    emit:
        filtered_fastq    // channel: [ val(meta), path(decontaminated fastq) ]
        nanoplot_reads_out   = NANOPLOT.out.html
        centrifuge_out       = CENTRIFUGE_KREPORT.out.kreport
        est_genome_size      = EXTRACT.out.genome_size_est
        
    versions = ch_versions                     // channel: [ versions.yml ]
}