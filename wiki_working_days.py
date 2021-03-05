import requests
import bs4

import sqlalchemy


def boilsoup():
    response = requests.get(
        'https://en.wikipedia.org/wiki/Workweek_and_weekend'
    )
    # print(response.content)
    if response.status_code == 200:
        soup = bs4.BeautifulSoup(response.text, 'html.parser')
        header_soup = soup.find('table').find_next('table').find_next('table').find_all('th')
        data_soup = soup.find('table').find_next('table').find_next('table').find_next('tbody').find_all('td')
    else:
        print('wrong_link')

    return header_soup, data_soup


def clean_data(header_soup, data_soup):
    header = [item.text for item in header_soup]
    data = [item.text for item in data_soup]
    print(header)
    print(data)
    return header, data


def decode_data(data):
    pass


def main():
    header_soup, data_soup = boilsoup()
    header, data = clean_data(header_soup, data_soup)
    decode_data(data)


if __name__ == '__main__':
    main()