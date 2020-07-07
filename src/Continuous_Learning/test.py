
    for j in range(i+1):
        print()
import io;
import sys

def main(argv):

    if(len(argv) < 1 or argv[0] == "-h" or argv[0] == "--help"):
        print("Usage: python codrep-compare.py /path/to/test/data /path/to/output")
        print("this program will look for predictions in the file: Codrep_Results/<date>/codrep-result.txt")
        exit(0)

    date_arr = ["16052020-1254", "19052020-1854", "22052020-1335", "23052020-2335"]
    
    for i in range(len(date_arr)):
        patches_files = []
        matches_found_no_repeat = 0
        matches_found_total = 0

        for j in range(i+1):
            date = date_arr[j]

            n = 50
            path_to_predictions_1 = f"/pfs/nobackup/home/j/javierro/sequencer/src/Continuous_Learning/Codrep_Results/1/{date}/predictions.txt"
            path_to_predictions_2 = f"/pfs/nobackup/home/j/javierro/sequencer/src/Continuous_Learning/Codrep_Results/2/{date}/predictions.txt"
            path_to_predictions_3 = f"/pfs/nobackup/home/j/javierro/sequencer/src/Continuous_Learning/Codrep_Results/3/{date}/predictions.txt"

            path_to_test_data = argv[0]
            path_to_output = argv[1]

            target_file = io.open(path_to_test_data, "r", encoding="utf-8")
            patches_file_1 = io.open(path_to_predictions_1, "r", encoding="utf-8")
            patches_file_2 = io.open(path_to_predictions_2, "r", encoding="utf-8")
            patches_file_3 = io.open(path_to_predictions_3, "r", encoding="utf-8")

            patches_files = patches_files + [patches_file_1, patches_file_2, patches_file_3]
            
        target_lines = target_file.readlines()

        for target_line in target_lines:
            found = 0
            for x in patches_files:
                for i in range(n):
                    patch_line = x.readline()

                    if(patch_line == target_line):
                        matches_found_total += 1
                        if(found == 0):
                            matches_found_no_repeat += 1
                        found = 1
        
        for x in patches_files:
            x.close()

        print("found fixes for " + str(matches_found_no_repeat) + " bugs")
        print("found " + str(matches_found_total) + " total fixes")

        print("analized " + str(len(target_lines)) + " total changes")

        with open(path_to_output, "a") as result_file:
            result_file.write(f"{str(matches_found_total)},{str(matches_found_no_repeat)},{str(len(target_lines))},{date},greedy\n")


if __name__=="__main__":
    main(sys.argv[1:])
