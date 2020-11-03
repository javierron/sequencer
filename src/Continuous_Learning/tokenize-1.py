import javalang
import sys
import os
import glob
import io
import json
from datetime import datetime

def main(argv):

    if(len(argv) < 1 or argv[0] == "-h" or argv[0] == "--help"):
        print("Usage: python tokenize-1.py /path/to/patch")
        exit(0)

    file = argv[0]
    patch_line_pos = int(file[file.rfind("-") + 1:])
    tgt_file = io.open("tmp/tgt-single.txt", "w", encoding="utf-8")

    fo = io.open(file, "r", encoding="utf-8")
    full_filename = file[:file.rfind("/") + 1] + fo.readline().strip() # get full filename
    fo.readline() # skip hunk header
    hunk_file_lines = fo.readlines()
    fo.close()

    target_line = ""

    plus_relative_position = 0

    if(full_filename.startswith("@")):
        print(file)

    try:
        added_line = ''
        removed_line = ''
        for line in hunk_file_lines:
            if(line.startswith("+")):
                added_line = line.replace('+', '', 1).strip()
                break
            elif(line.startswith("-")):
                removed_line = line.replace('-', '', 1).strip()
                plus_relative_position -= 1

            plus_relative_position += 1 
        
        if(added_line.startswith("*") or target_line.startswith("//")):
            raise Exception("change inside comment") # javalang package does not handle comment tokens
        if(added_line == '' or removed_line == ''):
            raise Exception("whitespace-only lines are unsupported")

        target_tokens = ""
        tokens = list(javalang.tokenizer.tokenize(added_line))
        for token in tokens:
            target_tokens = target_tokens + " " + token.value
            
        tgt_file.write(target_tokens + '\n')
        tgt_file.close()

        plus_position = patch_line_pos + plus_relative_position
        print(str(plus_position) + " " + str(full_filename))

        exit(0)

    except Exception as e:
        sys.stderr.write("Tokenization failed for file " + file + " " + str(e) + "\n")
        sys.exit(0)
    


if __name__=="__main__":
    main(sys.argv[1:])
