FROM node:18-bullseye-slim

LABEL email="khskeb0513@gmail.com"
LABEL name="Hyeonseung Kang"
LABEL version="1.2"
LABEL description="Helps Ajou University students use the printing system who use various OS. 다양한 운영체제를 사용하는 아주대학교 학생들이 인쇄 시스템을 사용할 수 있도록 돕습니다."

WORKDIR /usr/src/app
COPY . .
RUN apt update
RUN apt install git -y
RUN apt install -y ./driver/cnrdrvcups-ufr2-uk_5.70-1.05_amd64.deb || apt install -y ./driver/cnrdrvcups-ufr2-uk_5.70-1.05_arm64.deb || apt install -y ./driver/cnrdrvcups-ufr2-uk_5.70-1.05_i386.deb
CMD rm -rf ajou-print/ && git clone https://github.com/khskeb0513/ajou-print.git && service cups start && lpadmin -p "AJOU_PRINT" -D "아주대학교 프린트" -E -m CNRCUPSIRADV45253ZK.ppd -v "http://127.0.0.1:3000" && cd ajou-print && npm run start
EXPOSE 3000
EXPOSE 631
