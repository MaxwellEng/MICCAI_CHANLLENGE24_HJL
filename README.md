1. The download link for the model weights: https://pan.sjtu.edu.cn/web/share/f6751ef650a417551ba9cefe946a0214, Access code: dfsk
2. Ensure that the nnunetv2 is installed correctly  
3. You can change the input file path and output file path in 'new_inference_code.py', lines #1202 and #1203:
"""
    input_path    = INPUT_PATH / "images/ct-angiography"
    result_folder = OUTPUT_PATH / "images/aortic-branches"
"""
to your local file path.
4. Then run the command: python new_inference_code.py
