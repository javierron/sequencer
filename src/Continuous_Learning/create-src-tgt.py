import io
import sys
import re

def main(argv):

    output_file_src = io.open('src-passing.txt', 'w', encoding="utf-8") 
    output_file_tgt = io.open('tgt-passing.txt', 'w', encoding="utf-8") 

    src_file = io.open('../../results/Golden/src-test.txt', 'r', encoding="utf-8")
    sources = src_file.readlines()

    regex = re.compile('^(.*),([0-9]+)$')

    input_file = io.open("training-passed", "r", encoding="utf-8")
    input_lines = input_file.readlines()
    inputs = []

    for line in input_lines:
        m = regex.match(line)
        inputs.append((m.group(1), m.group(2)))
    

    for x in inputs:
        output_file_src.write(sources[x[1]])
        output_file_tgt.write(f"{x[0]}\n")

    output_file_src.close()
    output_file_tgt.close()


if __name__=="__main__":
    main(sys.argv[1:])
