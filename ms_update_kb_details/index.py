import argparse
import csv
import pprint
import requests
from bs4 import BeautifulSoup


def csv_load(file):
    """
    CSVファイルをloadする
    """
    csv_file = open(file=file)
    f = csv.reader(csv_file, delimiter=',')
    h_csv = []
    for row in f:
        h_csv.append(row)
    print(h_csv)
    return h_csv


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
    r = requests.get(
        url, headers={'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8'})
    if r.status_code != 200:
        raise Exception('HTTP STATUS is not 200.')

    html_soup = BeautifulSoup(r.text, 'html.parser')
    sections = html_soup.find_all('section', class_='ocpSection')
    values = []

    for section in sections:
        if section.h2 == None:
            continue
        if section.h2.text != 'この更新プログラムに関する既知の問題':
            continue

        table = section.find('table', class_='banded')
        if table == None:
            break

        for row in table.find_all('tr')[1:]:
            for col in row.find_all(['th', 'td']):
                values.append(col.text)
    return values


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Get KBXXXXX Information.")
    parser.add_argument('-f', '--file')
    args = parser.parse_args()

    url_list = make_kb_support_urls(csv_load(args.file))

    pprint.pprint(url_list)

    result = []
    for url in url_list:
        problem = request_ms_help_page(url)
        if len(problem) == 0:
            continue
        result.append({url: problem})
    pprint.pprint(result)
