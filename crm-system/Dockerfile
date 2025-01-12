# 使用官方 Node.js 鏡像
FROM node:18

# 設定工作目錄
WORKDIR /usr/src/app

# 複製 package.json 並安裝依賴
COPY package*.json ./
RUN npm install

# 複製程式碼
COPY . .

# 暴露端口
EXPOSE 3000

# 啟動應用
CMD ["npm", "run", "dev"]