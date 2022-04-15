import datetime
import os

from elasticsearch import Elasticsearch


def main():
    host = os.getenv('CONNECTION_STRING')
    es: Elasticsearch = Elasticsearch(hosts=host)
    query3(es)


def query1(es: Elasticsearch):
    """
    What are the top 10 most upvoted comments of all time? Print the comment and the score in an ordered list.
    :param es: Elastic Search API
    """
    indices = list(es.indices.get_alias().keys())
    top_comments = []
    query = {
        "query_string": {
            "query": "*"
        }
    }
    sort = [
        {
            "score": {
                "unmapped_type": "keyword",
                "order": "desc"
            }
        }
    ]
    res = es.search(
        index=indices,
        query=query,
        sort=sort,
        size=10
    )
    comments = res.body["hits"]["hits"]
    for comment in comments:
        data = comment["_source"]
        if len(top_comments) < 10:
            top_comments.append(data)
            continue
        for top_comment in top_comments:
            if top_comment["score"] < data["score"]:
                top_comments.remove(top_comment)
                top_comments.append(data)
    for top_comment in top_comments:
        print(f"[COMMENT SCORE] {top_comment['score']}\n[COMMENT]: {top_comment['body']}")
        print(f"=================================")
        print("\n")


def query2(es: Elasticsearch):
    """
    How many of the comments listed as controversial are also listed as an edited comment?
    :param es: Elastic Search API
    """
    indices = list(es.indices.get_alias().keys())
    query = {
        "bool": {
            "must": [
                {
                    "match": {
                        "controversiality": 1
                    }
                },
                {
                    "match": {
                        "edited": True
                    }
                }
            ]
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

    total = len(comments)
    print(f"total controversial comments: {total}")


def query3(es: Elasticsearch):
    """
    What percentage of the controversial comments were made at night (after 10pm)?
    :param es: Elastic Search API
    """
    indices = list(es.indices.get_alias().keys())
    query = {
        "match": {
            "controversiality": 1
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
    total = 0
    comments_late = []
    for comment in comments:
        data = comment['_source']
        date = datetime.datetime.fromtimestamp(data['created_utc'])
        if date.hour > 22:
            total += 1
            comments_late.append(data)
    print(f"total controversial comments after 10pm: {total}")
    for comment in comments_late:
        date = datetime.datetime.fromtimestamp(comment['created_utc'])
        print(f"[COMMENT TIME]: {date.time()}\n[COMMENT]: {comment['body']}")
        print(f"=================================")
        print("\n")



def query4(es: Elasticsearch):
    """
    What is the percentage of comments with the word sorry in them and are also replying to another comment?
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
