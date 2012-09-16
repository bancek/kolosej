import urllib
from lxml import objectify
from pyquery import PyQuery as pq
from flask import Flask, render_template, Response, jsonify, request
from werkzeug.contrib.cache import SimpleCache
from xml_to_json import xml_to_py

app = Flask(__name__)

cache = SimpleCache()

@app.route('/')
def index():
    return render_template('app.html')

@app.route('/movies')
def movies():
    data = cache.get('movies')

    if data is None:
        src = urllib.urlopen('http://www.kolosej.si/spored/xml/2.0/').read()
        xml = objectify.fromstring(src)
        data = xml_to_py(xml)

        cache.set('movies', data, timeout=5 * 60)

    return jsonify(movies=data)

@app.route('/movies/<slug>')
def movies_extra(slug):
    url = 'http://www.kolosej.si/filmi/film/%s/' % slug

    data = {}

    d = pq(url=url)
    for link in d('.links a'):
        if link.text == 'IMDB':
            data['imdb'] = link.attrib['href']
            d = pq(url=data['imdb'])
            data['imdb_rating'] = d('.star-box-giga-star').text()

    return jsonify(**data)

if __name__ == '__main__':
    app.run(debug=True) 
