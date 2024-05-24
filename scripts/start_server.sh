sudo apt install -y python3 python3-pip
pip3 install -r requirements.txt
nohup python3 manage.py runserver 0.0.0.0:8000 &
