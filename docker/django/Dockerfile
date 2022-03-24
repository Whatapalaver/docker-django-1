FROM python:3.7-slim-buster
RUN mkdir /code
WORKDIR "/code"

ENV PYTHONUNBUFFERED=1

# install build dependencies
RUN apt-get update && apt-get install --assume-yes --quiet --no-install-recommends \
    git \
    build-essential

# install python dependencies, use latest pip
COPY requirements.txt /code/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# copy everything that needs to be in the image
COPY . /code/
