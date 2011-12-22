. /etc/profile
cd /sites/rails/prod/cms
ruby script/runner 'CronManager.read_and_save_rss' -e production
