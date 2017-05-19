# Run from Vagrantfile the first time a VM is provisioned.
# To run again, you must do vagrant destroy
 

# operating system dependencies for virtualbox additions 

#  test without these
#yum update -y # slow
#yum update -y kernel
# helps for vbox additions yum install -y kernel-devel
# note that dkms, often recommended for virtualbox, is unsstable in Centos

# could mount iso and
# cd /media/VirtualBoxGuestAdditions
# ./VBoxLinuxAdditions.run

# our dependencies
yum groupinstall -y 'Development Tools'
yum install -y graphviz

#Install miniconda - remove any previous folders for miniconda
rm -r /home/vagrant/miniconda3/ || true
for i in 1 2 3 4 5; do
        wget -c http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && break
        sleep 15
        echo 'Retrying bash download'
done

bash Miniconda3-latest-Linux-x86_64.sh <<HERE1
yes
\r
\r
yes
miniconda3
no
HERE1

# import the Python dependencies
/home/vagrant/miniconda3/bin/conda create --name nosonomy
for i in 1 2 3 4 5; do
        /home/vagrant/miniconda3/bin/conda env update -n nosonomy -f /vagrant/environment.yml && break
	sleep 15
	echo 'Retrying conda env create'
done

#source activate root
# allow vagrant user to traverse to ananconda folder
chmod a+x /root
#echo 'export PATH=$PATH:/home/vagrant/miniconda3/bin/' >> /home/vagrant/.bashrc
echo 'source activate nosonomy' >> /home/vagrant/.bashrc

# install infomap, see http://www.mapequation.org/code.html
mkdir infomap
cd infomap/
curl -v http://www.mapequation.org/downloads/Infomap.zip >  Infomap.zip
unzip Infomap.zip
make

# get data
curl http://ctdbase.org/reports/CTD_diseases_pathways.csv.gz > /vagrant/data/CTD_diseases_pathways.csv.gz
echo 'Loaded data from Comparative Toxicogenomics Database'


# note that jupyter will use root environment when started by systemd

# config for jupyter
# note that the port is open
# the host machine is responsible for firewalling.
#mkdir /etc/jupyter/
#cat > /etc/jupyter/jupyter_notebook_config.py <<HERE
#c.NotebookApp.ip = '*'
#c.NotebookApp.notebook_dir = '/vagrant/notebooks' 
#c.NotebookApp.token = u''
#HERE
# TODO see http://stuartmumford.uk/blog/jupyter-notebook-and-conda.html 

# enable jupyter
#cat > /usr/lib/systemd/system/jupyter.service <<HERE0
#[Unit]
#Description=jupyter

#[Service]
#Type=simple
#Environment="PATH=/home/vagrant/miniconda3/bin:/usr/local/bin:/usr/bin"
#PIDFile=/var/run/jupyter.pid
#User=vagrant
#ExecStart=/home/vagrant/miniconda3/bin/jupyter notebook --no-browser
#WorkingDirectory=/vagrant/notebooks

#[Install]
#WantedBy=multi-user.target
#HERE0

# TODO ln -s '/usr/lib/systemd/system/ipython-notebook.service' '/etc/systemd/system/multi-user.target.wants/ipython-notebook.service'
#systemctl daemon-reload
#systemctl enable jupyter

# also done as a trigger after up
#systemctl start jupyter
