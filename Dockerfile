# Pull the docker image
FROM --platform=linux/amd64 pytorch/pytorch

FROM python:3.10-slim
ENV PYTHONUNBUFFERED 1
RUN groupadd -r user && useradd -m --no-log-init -r -g user user

RUN mkdir -p /opt/app /input /output \
    && chown user:user /opt/app /input /output

USER user
WORKDIR /opt/app

ENV PATH="/home/user/.local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
COPY --chown=user:user requirements.txt /opt/app/


RUN python -m pip install --user -U pip && python -m pip install --user pip-tools
RUN python -m piptools sync requirements.txt

# RUN python -m pip install --user -r requirements.txt
# RUN python -m pip install --user torch==1.12.0+cu116 torchvision==0.13.0+cu116 torchaudio==0.12.0 --extra-index-url https://download.pytorch.org/whl/cu116
# RUN python -m pip install --user torch==2.0.0+cu117  torchvision==0.15.1+cu117 torchaudio==2.0.1 --extra-index-url https://download.pytorch.org/whl/cu117
# RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN python -m pip install --no-deps --user nnunetv2

COPY --chown=user:user nnunetv2 /opt/app/
COPY --chown=user:user new_inference_code.py /opt/app/
COPY --chown=user:user post_processing.py /opt/app/
# COPY --chown=user:user images/ /opt/app/images/
COPY --chown=user:user resources/ /opt/app/resources/
# COPY --chown=user:user output/ /opt/app/


ENTRYPOINT [ "python", "-m", "new_inference_code" ]
