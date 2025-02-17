import json
from datetime import datetime
import pytz
from aws_driver import AWSOps
from postgres_driver import PostgresDatabaseDriver


driver = PostgresDatabaseDriver()


def insert_game_data(driver, games, filename, etl_ts):
    try:
        insert_statement = """
            INSERT INTO landing.plays (plays_json, filename, etl_ts)
            VALUES (%s, %s, %s)
        """
        for drive in games:
            for play in drive['plays']:
                play_json = json.dumps(play)
                driver.execute(insert_statement, (play_json, filename, etl_ts))
        driver.commit()
    except Exception as e:
        print("Error inserting events:", e)
        driver.conn.rollback()


def insert_team_data(driver, teams, filename, etl_ts):
    try:
        insert_statement = """
            INSERT INTO landing.teams (team_json, filename, etl_ts)
            VALUES (%s, %s, %s)
        """
        for team in teams:
            team_json = json.dumps(team)
            driver.execute(insert_statement, (team_json, filename, etl_ts))
        driver.commit()
    except Exception as e:
        print("Error inserting events:", e)
        driver.conn.rollback()


def insert_scoring_play_data(driver, scores, filename, etl_ts):
    try:
        insert_statement = """
            INSERT INTO landing.scoring_plays (score_json, filename, etl_ts)
            VALUES (%s, %s, %s)
        """
        for score in scores:
            score_json = json.dumps(score)
            driver.execute(insert_statement, (score_json, filename, etl_ts))
        driver.commit()
    except Exception as e:
        print("Error inserting events:", e)
        driver.conn.rollback()


# def insert_player_stats_data(driver, stats, filename, etl_ts):
#     try:
#         insert_statement = """
#             INSERT INTO landing.player_stats (stats_json, filename, etl_ts)
#             VALUES (%s, %s, %s)
#         """
#         for stat in stats:
#             stat_json = json.dumps(stat)
#             driver.execute(insert_statement, (stat_json, filename, etl_ts))
#         driver.commit()
#     except Exception as e:
#         print("Error inserting events:", e)
#         driver.conn.rollback()


def load_game_details_to_database():
    s3 = AWSOps.connectS3()
    bucket = AWSOps.getBucketName('nfl_s3_bucket')
    folder = 'games/'

    try:
        file_list = s3.list_objects_v2(Bucket=bucket, Prefix=folder)
        eastern_tz = pytz.timezone('US/Eastern')

        if 'Contents' in file_list:
            for file in file_list['Contents']:
                key = file['Key']
                if not key.endswith('/'):
                    data = AWSOps.getJsonFileBody(s3, bucket, key)

                    filename = key.split('/', 1)[1]
                    teams = data['boxscore']['teams']
                    player_stats = data['boxscore']['players']
                    plays = data['drives']['previous']
                    scores = data['scoringPlays']

                    if teams:
                        ts = datetime.now(eastern_tz)
                        etl_ts = ts.isoformat()
                        insert_team_data(driver, teams, filename, etl_ts)
                        print(f"Teams in file [{key}] uploaded successfully")
                    else:
                        print(f"No teams found in [{key}]")

                    # if player_stats:
                    #     ts = datetime.now(eastern_tz)
                    #     etl_ts = ts.isoformat()
                    #     insert_player_stats_data(driver, player_stats, filename, etl_ts)
                    #     print(f"Player stats in file [{key}] uploaded successfully")
                    # else:
                    #     print(f"No stats found in [{key}]")

                    if plays:
                        ts = datetime.now(eastern_tz)
                        etl_ts = ts.isoformat()
                        insert_game_data(driver, plays, filename, etl_ts)
                        print(f"Plays in file [{key}] uploaded successfully")
                    else:
                        print(f"No plays found in [{key}]")

                    if scores:
                        ts = datetime.now(eastern_tz)
                        etl_ts = ts.isoformat()
                        insert_scoring_play_data(driver, scores, filename, etl_ts)
                        # s3.delete_object(Bucket=bucket, Key=key)
                        print(f"Scoring plays in file [{key}] uploaded successfully")
                    else:
                        print(f"No scoring plays found in [{key}]")
        else:
            print("No contents found")
            return
    except Exception as e:
        print(f"Error loading files to database: {e}")
    finally:
        driver.close()



if __name__ == '__main__':
    load_game_details_to_database()