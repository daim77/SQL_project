import requests
import bs4
import pandas as pd
from pprint import pprint as pp

import sqlalchemy as db


def boilsoup():
    response = requests.get(
        'https://en.wikipedia.org/wiki/Workweek_and_weekend'
    )
    # print(response.content)
    if response.status_code == 200:
        soup = bs4.BeautifulSoup(response.text, 'html.parser')
        header_soup = \
            soup.find('table').find_next('table')\
                .find_next('table').find_all('th')
        data_soup = \
            soup.find('table').find_next('table').find_next('table')\
                .find_next('tbody').find_all('td')
        return header_soup, data_soup
    else:
        print('wrong_link')
        exit()


def prepare_data(header_soup, data_soup):
    # header = [item.text.strip('\n') for item in header_soup]
    data_list = [item.text.strip('\n') for item in data_soup]
    header = [
        'country',
        'working_hrs_per_week',
        'working_days',
        'working_hrs_per_day'
    ]
    data = []
    data_sublist = []
    counter = 0

    for item in data_list:
        counter += 1
        if counter % 4 == 0:
            data_sublist.append(int(item.split()[0][:1]))
            data.append(data_sublist)
            data_sublist = []
            counter = 0
            continue
        elif counter == 1:
            data_sublist.append(item.split(' (')[0])
            continue
        elif counter == 2:
            data_sublist.append(int(item.split()[0][:2]))
        elif counter == 3:
            data_sublist.append(
                item.split()[0].split('[')[0].split('(')[0]
                    .replace('–', '-').replace('-', '-')
            )
        else:
            data_sublist.append(int(item.split()[0].strip('.')))
            continue
    return header, data


def data_to_frame(header, data):
    df = pd.DataFrame(data, columns=header)
    # working days coding as SQL DAYOFWEEK() 1: sunday, 7: saturday
    dict_values = {
        'Saturday-Wednesday': '7, 1, 2, 3, 4,',
        'Monday-Friday': '2, 3, 4, 5, 6',
        'Sunday-Thursday': '1, 2, 3, 4, 5',
        'Monday-Saturday': '2, 3, 4, 5, 6, 7',
        'Monday-Thursday': '2, 3, 4, 5, 7',
        'Saturday-Thursday': '7, 1, 2, 3, 4, 5',
        'Sunday-Friday': '1, 2, 3, 4, 5, 6'
    }
    df['working_days'] = df['working_days'].map(dict_values)
    return df


def non_regular(df):
    non_reg_country = []
    for index in range(df.shape[0]):
        if df.iloc[index]['working_days'] != '2, 3, 4, 5, 6':
            non_reg_country.append(df.iloc[index]['country'])
    pp(non_reg_country)
    pp(len(non_reg_country))
    # non_reg_days = list(df['working_days'].unique())
    # pp(non_reg_days)
    return


def data_to_sql(df):
    # df.set_index('country', inplace=True)
    user = "student"
    password = "p7@vw7MCatmnKjy7"
    conn_string = f"mysql+pymysql://{user}:{password}@data.engeto.com/data"
    engeto_conn = db.create_engine(conn_string)
    connection = engeto_conn.connect()
    return


def main():
    header_soup, data_soup = boilsoup()
    header, data = prepare_data(header_soup, data_soup)
    df = data_to_frame(header, data)
    non_regular(df)

    data_to_sql(data)

    with pd.option_context(
            'display.max_rows', None,
            'display.max_columns', None
    ):
        print(df)



if __name__ == '__main__':
    main()
