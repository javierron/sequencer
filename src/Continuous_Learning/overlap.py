
import io
import sys

def main(argv):

    if(len(argv) < 3 or argv[0] == "-h" or argv[0] == "--help"):
        print("Usage: python overlap.py /path/to/predictions/1 /path/to/predictions/2 /path/to/test_data /path/to/output")
        exit(0)

    n = 50
    path_to_predictions_1 = argv[0]
    path_to_predictions_2 = argv[1]
    path_to_test_data = argv[2]
    path_to_output = argv[3]

    target_file = io.open(path_to_test_data, "r", encoding="utf-8")
    patches_file_1 = io.open(path_to_predictions_1, "r", encoding="utf-8")
    patches_file_2 = io.open(path_to_predictions_2, "r", encoding="utf-8")

    target_lines = target_file.readlines()

    matches_found_no_repeat_1 = 0
    matches_found_total_1 = 0

    matches_found_no_repeat_2 = 0
    matches_found_total_2 = 0

    overlap = 0
    target_lines_index = 0
    for target_line in target_lines:
        found_1 = 0
        for i in range(n):
            patch_line_1 = patches_file_1.readline()
            
            if(patch_line_1 == target_line):
                matches_found_total_1 += 1
                if(found_1 == 0):
                    matches_found_no_repeat_1 += 1
                found_1 = 1
        
        found_2 = 0
        for i in range(n):
            patch_line_2 = patches_file_2.readline()
            
            if(patch_line_2 == target_line):
                matches_found_total_2 += 1
                if(found_2 == 0):
                    matches_found_no_repeat_2 += 1
                found_2 = 1
            
        
        if(found_1 == 1 and found_2 == 1):
            overlap = overlap + 1
        
        target_lines_index += 1


    print("file 1: found fixes for " + str(matches_found_no_repeat_1) + " bugs")
    print("file 1: found " + str(matches_found_total_1) + " total fixes")

    print("file 2: found fixes for " + str(matches_found_no_repeat_2) + " bugs")
    print("file 2: found " + str(matches_found_total_2) + " total fixes")

    print("overlap: found " + str(overlap) + " overlapping changes")


    print("analized " + str(len(target_lines)) + " total changes")

    with open(path_to_output, "w") as result_file:
        result_file.write(str(matches_found_no_repeat_1) + "," + str(matches_found_no_repeat_2) + "," + str(overlap))


    target_file.close()
    patches_file_1.close()
    patches_file_2.close()

if __name__=="__main__":
    main(sys.argv[1:])
