import pprint
import bs4
import requests
from bs4 import BeautifulSoup
import time
import typing as tp
import json


def html_soup(res: tp.Type[requests.Response]):
    return BeautifulSoup(res.content, 'html.parser')


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


def h1(bsoup: tp.Type[bs4.BeautifulSoup]):
    h1s = bsoup.find_all('h1')
    result = []
    for h in h1s:
        if h.text.strip() != '':
            result.append(h.text.strip())
    return result


def h2(bsoup: tp.Type[bs4.BeautifulSoup]):
    h2s = bsoup.find_all('h2')
    result = []
    for h in h2s:
        if h.text.strip() != '':
            result.append(h.text.strip())
    return result


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
                'title': title(bsoup),
                'description': description(bsoup),
                'h1': h1(bsoup),
                'h2': h2(bsoup)
            }
        )
        time.sleep(2)
    
    with open('mydata.json', mode='wt', encoding='utf-8') as file:
        json.dump(result, file, ensure_ascii=False, indent=2)

    pprint.pprint('Finish!')
