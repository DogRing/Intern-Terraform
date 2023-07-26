# !/bin/bash
apt-get update;
apt-get upgrade -y;
apt-get install -y openjdk-8-jdk;
apt-get install -y openjdk-11-jdk;
cd /usr/lib/jvm;
wget https://cdn.azul.com/zulu/bin/zulu7.56.0.11-ca-jdk7.0.352-linux_x64.tar.gz;
tar -xvf zulu7.56.0.11-ca-jdk7.0.352-linux_x64.tar.gz;
rm zulu7.56.0.11-ca-jdk7.0.352-linux_x64.tar.gz;
ln -s zulu7.56.0.11-ca-jdk7.0.352-linux_x64 zulu-7-amd64;
wget https://gist.github.com/egibbm/e3c2435a7e7b6d67596ab739649c4078/raw/78ed5c508ede8dd2cb13cb5e00c3bd5da1042d98/.zulu-7-amd64.jinfo;
wget https://gist.github.com/egibbm/e3c2435a7e7b6d67596ab739649c4078/raw/78ed5c508ede8dd2cb13cb5e00c3bd5da1042d98/install-zulu-to-alternative.sh;
chmod a+x install-zulu-to-alternative.sh;
./install-zulu-to-alternative.sh;

echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile;
echo "export JAVA_7_HOME=/usr/lib/jvm/zulu-7-amd64" >> /etc/profile;
echo "export JAVA_8_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/profile;
echo "export JAVA_11_HOME=/usr/lib/jvm/java-11-openjdk-amd64" >> /etc/profile;
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile;
source /etc/profile;

cd /;
wget https://archive.apache.org/dist/hbase/1.2.7/hbase-1.2.7-bin.tar.gz;
tar xzvf hbase-1.2.7-bin.tar.gz;
rm hbase-1.2.7-bin.tar.gz;
chown -R ubuntu: hbase-1.2.7;
cd hbase-1.2.7;
./bin/start-hbase.sh;
wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/master/hbase/scripts/hbase-create.hbase;
./bin/hbase shell ./hbase-create.hbase;

cd /;
sudo apt-get install -y mysql-server;
sed -i "s|# port|port|g" /etc/mysql/mysql.conf.d/mysqld.cnf;
sed -i "s|3306|13306|g" /etc/mysql/mysql.conf.d/mysqld.cnf;

systemctl start mysql;
systemctl enable mysql;

wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/master/web/src/main/resources/sql/CreateTableStatement-mysql.sql;
wget https://raw.githubusercontent.com/pinpoint-apm/pinpoint/master/web/src/main/resources/sql/SpringBatchJobRepositorySchema-mysql.sql;

mysql -uroot <<QUERY
create database pinpoint;
create user 'admin'@'localhost' identified by 'admin';
flush privileges;
grant all privileges on *.* to 'admin'@'localhost';
flush privileges;
use pinpoint;
source /CreateTableStatement-mysql.sql
source /SpringBatchJobRepositorySchema-mysql.sql
QUERY

cd /home/ubuntu
git clone https://github.com/pinpoint-apm/pinpoint.git
chown -R ubuntu: pinpoint
# jdbc(web,batch) ?useSSL=false
cd pinpoint
git checkout tags/v2.4.2
./mvnw clean install -DskipTests=true

