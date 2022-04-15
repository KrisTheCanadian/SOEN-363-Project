import os

from elasticsearch import Elasticsearch


def main():
    host = os.getenv('CONNECTION_STRING')
    es: Elasticsearch = Elasticsearch(hosts=host)
    query4(es)


def query4(es: Elasticsearch):
    """
    How many of the comments with the word sorry in them are replying to another comment?
    :param es: Elastic Search API
    """
    indices = list(es.indices.get_alias().keys())
    total: float = 0
    total_replies: float = 0
    query = {
        "match": {
            "body": "sorry"
        }
    }
    res = es.search(
        index=indices,
        query=query,
        scroll='2m',
        size=1000
    )
    # Get the scroll ID
    sid = res['_scroll_id']
    scroll_size = len(res['hits']['hits'])
    comments = []
    while scroll_size > 0:
        "Scrolling..."

        # Before scroll, process current batch of hits
        ##
        for item in res['hits']['hits']:
            comments.append(item)

        data = es.scroll(scroll_id=sid, scroll='2m')

        # Update the scroll ID
        sid = data['_scroll_id']

        # Get the number of results that returned to the last scroll
        scroll_size = len(data['hits']['hits'])

    total = total + len(comments)

    for comment in comments:
        data = comment["_source"]
        if data['parent_id'] != data['link_id']:
            total_replies += 1

    if total != 0:
        percentage = total_replies / total * 100
        print(f"total replies: {total_replies} of total comments: {total} that has the word sorry.")
        print("{:.{}f}%".format(percentage, 4))
    else:
        print("0%")


if __name__ == '__main__':
    main()
