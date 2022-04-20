import os
from multiprocessing import Process
from os import listdir
from os.path import isfile, join

import requests


def main():
    host = os.getenv('CONNECTION_STRING')
    mypath = "/home/viking/DEV/SOEN-363-Project/DATA"

    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    print(onlyfiles)

    header = {"Content-Type": "application/json"}
    process_list = []
    for file in onlyfiles:
        process_list.append(Process(target=upload_data, args=(file, header, mypath, host)))

    for process in process_list:
        process.start()

    for process in process_list:
        process.join()


def upload_data(file, header, mypath, host):
    full_path = mypath + '/' + file
    with open(full_path) as file_handle:
        jsons = file_handle.readlines()
        counter = 0
        for json in jsons:
            res = requests.post(f"{host}{file.lower()}/_doc", data=json,
                                headers=header)
            if res.status_code != 200 and res.status_code != 201:
                print(f"FAIL FILE: {file} LINE: {counter} RESPONSE: {res}")
            counter = counter + 1


if __name__ == '__main__':
    main()
