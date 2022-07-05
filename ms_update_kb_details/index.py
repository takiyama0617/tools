import argparse
import csv
import pprint
import requests
from bs4 import BeautifulSoup
import datetime


def load_csv(file):
    """
    CSVファイルをloadする
    """
    with open(file=file, encoding='utf-8') as csv_file:
        h_csv = []
        for row in csv.reader(csv_file, delimiter=','):
            h_csv.append(row)
        print(h_csv)
    return h_csv


def write_csv(data):
    """
    データをCSVファイルに書き込む
    ファイル名は、result_YYYYMMDD.csv
    """
    file_name = 'result_' + datetime.date.today().strftime('%Y%m%d') + '.csv'
    with open(f'./output/{file_name}', 'w', encoding='utf-8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=['url', 'problem'])
        writer.writeheader()
        for row in data:
            writer.writerow(row)


def make_kb_support_urls(kb_list):
    """
    KBXXXXXXX の配列からWindowsUpdateパッチのヘルプページのURLリストを生成する
    """
    TEMPLATE_URL = 'https://support.microsoft.com/help/'
    urls = []
    for tmp_list in kb_list:
        for kb in tmp_list:
            urls.append(TEMPLATE_URL + kb.removeprefix('KB'))
    return urls


def request_ms_help_page(url):
    """
    https://support.microsoft.com/help/XXXXXX のMSサポートページから 

    更新プログラムに既知の問題がある場合、その現象と回避策の情報をスクレイピングする
    """
    response = requests.get(
        url, headers={'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8'})
    if response.status_code != 200:
        pprint.pprint('http_status is not 200 ', url, response.status_code)
        return []

    html_soup = BeautifulSoup(response.text, 'html.parser')
    sections = html_soup.find_all('section', class_='ocpSection')
    values = []

    for section in sections:
        if section.h2 is None:
            continue
        if section.h2.text != 'この更新プログラムに関する既知の問題':
            continue

        table = section.find('table', class_='banded')
        if table is None:
            break

        for row in table.find_all('tr')[1:]:
            for col in row.find_all(['th', 'td']):
                values.append(col.text)
    return values


if __name__ == '__main__':
    pprint.pprint('Start!')
    parser = argparse.ArgumentParser(description="Get KBXXXXX Information.")
    parser.add_argument('-f', '--file')
    args = parser.parse_args()

    url_list = make_kb_support_urls(load_csv(args.file))

    pprint.pprint(url_list)

    result = []
    for url in url_list:
        problem = request_ms_help_page(url)
        if len(problem) == 0:
            continue
        result.append(
            {
                'url': url,
                'problem': problem
            })
    write_csv(result)
    pprint.pprint('Finish!')
