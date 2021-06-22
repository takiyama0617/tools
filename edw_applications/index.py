import argparse
import csv
import pprint
import bs4
import requests
from bs4 import BeautifulSoup
import time
import typing as tp


def html_soup(res: tp.Type[requests.Response]):
    return BeautifulSoup(res.text, 'html.parser')


def title(bsoup: tp.Type[bs4.BeautifulSoup]):
    return bsoup.find('title').text


def description(bsoup: tp.Type[bs4.BeautifulSoup]):
    meta = bsoup.find('meta', {'property': 'og:description'})
    if meta != None:
        return meta.get('content')
    else:
        return ''


def keyword(bsoup: tp.Type[bs4.BeautifulSoup]):
    return bsoup.find('meta', {'name': 'keyword'})

def get_request(url: str):
    return requests.get(
        url=url, headers={'Accept-Language': 'ja'}
    )

def get_edw_applications_urls():
    url = 'https://www.ricoh.co.jp/solutions/edw-application'
    r = get_request(url)
    if r.status_code != 200:
        raise Exception('HTTP STATUS is not 200.')

    bsoup = html_soup(r)
    section = bsoup.find('section', class_='recommend bg_c1d')
    urls = []
    for link in section.find_all('a')[1:]:
        url = link.get('href')
        if url.startswith('/'):
            url = 'https://www.ricoh.co.jp' + url
        urls.append(url)
    # pprint.pprint(urls)
    return urls

if __name__ == '__main__':
    pprint.pprint('Start!')

    urls = get_edw_applications_urls()
    result = []
    for url in urls:
        bsoup = html_soup(get_request(url))
        result.append(
            {
                'url': url,
                'title':title(bsoup),
                'description': description(bsoup)
            }
        )
        time.sleep(2)
    pprint.pprint(result)

    pprint.pprint('Finish!')
