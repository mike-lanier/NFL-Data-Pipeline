import json
import requests
from datetime import datetime
import pytz
from postgres_driver import PostgresDatabaseDriver


driver = PostgresDatabaseDriver()

def fetch_teams():
    try:
        response = requests.get('http://site.api.espn.com/apis/site/v2/sports/football/nfl/teams')

        if response.status_code == 200:
            json_data = response.json()
        else:
            return "No data available"
        
        teams = json_data['sports'][0]['leagues'][0]['teams']
        return teams
    except Exception as e:
        print(f"Error: {e}")

def insert_team_data(driver, teams, etl_ts):
    try:
        insert_statement = """
            INSERT INTO landing.teams (team_json, etl_ts)
            VALUES (%s, %s)
        """
        for team in teams:
            team_json = json.dumps(team)
            driver.execute(insert_statement, (team_json, etl_ts))
        driver.commit()
    except Exception as e:
        print("Error inserting events:", e)
        driver.conn.rollback()

def fetch_and_insert_teams():
    teams = fetch_teams()

    eastern_tz = pytz.timezone('US/Eastern')
    ts = datetime.now(eastern_tz)
    etl_ts = ts.isoformat()

    insert_team_data(driver, teams, etl_ts)

if __name__ == '__main__':
    fetch_and_insert_teams()
