## Directory Structure

Before we begin, let's familiarize ourselves with the directory structure required for our Docker setup:


```
DockerExample/
├─ resources/                         # Directory for resources such as your saved model and other necessary utilities
|  ├─ your_best_model.pth             # Your trained model file
|  └── ....                           # Additional dependencies for predictions
|
├── Dockerfile                        # Dockerfile script to build the Docker image (Don't change it if you are not an expert!)
├── inference.py                      # Python script for generating output segmentations (Modify it as per your need)
├── requirements.txt                  # List of Python packages required for execution        
├── save.sh                           # Shell script to package the Docker image into a .tar.gz file
└── test.sh                           # Shell script for local testing of the Docker image
```

---


1. The download link for the model weights: https://pan.sjtu.edu.cn/web/share/f6751ef650a417551ba9cefe946a0214, Access code: dfsk

2. Ensure that the nnunetv2 is installed correctly  

3. You can change the input file path and output file path in 'new_inference_code.py', lines #1202 and #1203:

"""
    input_path    = INPUT_PATH / "images/ct-angiography"
    result_folder = OUTPUT_PATH / "images/aortic-branches"
"""

to your local file path.

4. Then run the command: python new_inference_code.py
