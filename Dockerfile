FROM python:3.9.2-alpine

# upgrade pip
RUN pip install --upgrade pip

# get curl for healthchecks
RUN apk add curl

# permissions and nonroot user for tightened security
RUN adduser -D nonroot
RUN mkdir /home/app/ && chown -R nonroot:nonroot /home/app
RUN mkdir -p /var/log/flask-app && touch /var/log/flask-app/flask-app.err.log && touch /var/log/flask-app/flask-app.out.log
RUN chown -R nonroot:nonroot /var/log/flask-app
WORKDIR /home/app
USER nonroot

COPY --chown=nonroot:nonroot requirements.txt .
# venv
ENV VIRTUAL_ENV=/home/app/venv

# python setup
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN export FLASK_APP=app.py
RUN pip install -r requirements.txt

COPY --chown=nonroot:nonroot app.py .
COPY --chown=nonroot:nonroot config.py .
COPY --chown=nonroot:nonroot tasks.py .
COPY --chown=nonroot:nonroot templates ./templates
COPY --chown=nonroot:nonroot wsgi.py .

# define the port number the container should expose
EXPOSE 5000

CMD ["python", "app.py"]
