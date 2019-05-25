export IP=$(hostname -I | awk '{print $1}')
jupyter notebook --ip=$IP --allow-root