#!/usr/bin/env python
#from __future__ import with_statement

#from sys import stdin, stderr
from optparse import OptionParser
import vcf

THR = 0.1
REF = 0
def main():
    usage = '''
            multisample_vcf_tobinary -t af_thr multi.vcf > binary_calls_prior
            '''
    parser = OptionParser(usage=usage)
    parser.add_option('-t', '--thr', type=float, dest='thr', default=THR, help='minimum requested AF to call a SNP [default:'+ str(THR) + ']')
    parser.add_option('-r', '--ref', type=int, dest='ref', default=REF, help='index of sample which has been used as ref [default:'+ str(REF) + ']')

    options, args = parser.parse_args()

    if len(args) != 1:
        exit('Unexpected argument number.\n' + usage)
    
    vcf_file = vcf.Reader(open(args[0], 'r'))
    samples = vcf_file.samples
    print("\t".join(["ID"] + samples))
    for record in vcf_file:
        samples_af = [record.genotype(sampleID)['AF'] for sampleID in samples]
        good = any([x > options.thr for x in samples_af[:options.ref]+samples_af[options.ref+1:] if type(x) == float]) 
        # we skip the normal sample, being the reference it's never (on 1979) > 0.1
        # the check on floats removes multiallelic snps
        if good:
            alt_depths = [record.genotype(sampleID)['AD'][1] for sampleID in samples] # 2nd element is depth on mutated allele
            binary = ["1" if x>0 else "0" for x in alt_depths]
            print("\t".join([str(record.CHROM)+":"+str(record.POS)+":"+str(record.REF)+":"+str(record.ALT)] + binary))
            
        


if __name__ == '__main__':
    main()
