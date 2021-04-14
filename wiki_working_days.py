import requests
import bs4
import pandas as pd

import sqlalchemy as db


def boilsoup():
    response = requests.get(
        'https://en.wikipedia.org/wiki/Workweek_and_weekend'
    )
    if response.status_code == 200:
        soup = bs4.BeautifulSoup(response.text, 'html.parser')
        data_soup = \
            soup.find('table').find_next('table').find_next('table')\
                .find_next('tbody').find_all('td')
        return data_soup
    else:
        print('wrong_link')
        exit()


def prepare_data(data_soup):
    data_list = [item.text.strip('\n') for item in data_soup]

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
            data_sublist.append(item.split(' (')[0].strip('*'))
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
    return data


def data_to_frame(data):
    header = [
        'country',
        'working_hrs_per_week',
        'working_days',
        'working_hrs_per_day'
    ]
    df = pd.DataFrame(data=data, columns=header)

    # working days coding as SQL DAYOFWEEK() 1: sunday, 7: saturday
    dict_values = {
        'Saturday-Wednesday': '7, 1, 2, 3, 4',
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
    non_reg_country = \
        list(df[df['working_days'] != '2, 3, 4, 5, 6']['country'].values)
    print(non_reg_country)
    return


def data_to_sql(df):
    file1 = open(
        '/Users/martindanek/Documents/programovani/engeto_password.txt', "r")
    user_data = eval(file1.read())
    file1.close()

    user = user_data[0][0]
    password = user_data[0][1]

    conn_string = f"mysql+pymysql://{user}:{password}@data.engeto.com/data"
    engeto_conn = db.create_engine(conn_string, echo=True)

    db_connection = engeto_conn.connect()

    df.to_sql('t_martin_danek_project_SQL_workingdays',
              db_connection,
              if_exists='replace', index=False)
    db_connection.close()
    return


def main():
    data_soup = boilsoup()
    data = prepare_data(data_soup)
    df = data_to_frame(data)
    non_regular(df)

    data_to_sql(df)


if __name__ == '__main__':
    main()
