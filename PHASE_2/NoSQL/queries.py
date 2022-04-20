import time
import datetime
import os

from elasticsearch import Elasticsearch


def main():
    host = os.getenv('CONNECTION_STRING')
    es: Elasticsearch = Elasticsearch(hosts=host)
    query_number: int = int(input("Enter the query number you want to run: "))
    print('Result: \n')
    startTime = time.perf_counter()
    # I wish python had switch cases...
    if query_number == 1:
        query1(es)
    elif query_number == 2:
        query2(es)
    elif query_number == 3:
        query3(es)
    elif query_number == 4:
        query4(es)
    elif query_number == 5:
        query5(es)
    elif query_number == 6:
        query6(es)
    elif query_number == 7:
        query7(es)
    elif query_number == 8:
        query8(es)
    elif query_number == 9:
        query9(es)
    elif query_number == 10:
        query10(es)
    else:
        print("Invalid Query Number... Exiting Program...")

    finishTime = time.perf_counter()
    print(f"Time Taken: {finishTime- startTime}")

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


def query5(es: Elasticsearch):
    """
    Who were the top 3 users that commented the most in 2006? How many comments did they make and what was their top commented subreddit?
    :param es: Elastic Search API
    """
    indices: list[str] = list(es.indices.get_alias().keys())
    for index in indices[:]:
        if index.find("2007") != -1:
            indices.remove(index)
    query = {
        "match_all": {}
    }

    aggs = {
        "authors": {
            "terms": {
                "field": "author.keyword",
            }
        }
    }

    res = es.search(
        index=indices,
        query=query,
        aggs=aggs,
        scroll='2m',
        size=1000
    )
    authors = res.body['aggregations']['authors']['buckets']
    for author in authors[:4]:
        if author['key'] == '[deleted]':
            continue
        query = {
            "bool": {
                "must": [
                    {
                        "match": {
                            "author": author['key']
                        }
                    }
                ]
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
            size=1
        )
        if res['hits']['hits'][0] is not None:
            comment = res['hits']['hits'][0]['_source']
            print(f"[Author]: {author['key']} [Count]: {author['doc_count']} [Score]: {comment['score']} "
                  f"[SubReddit]: {comment['subreddit']} [Comment]: {comment['body']}")


def query6(es: Elasticsearch):
    """
    Find all comments about postgres. Display the number of comments that have a score between 15-30. Display the top comment and the lowest comment in that range
    :param es: Elastic Search API
    """
    indices = list(es.indices.get_alias().keys())
    query = {
        "bool": {
            "must": [
                {
                    "match": {
                        "body": "postgres"
                    }
                },
                {
                    "range": {
                        "score": {
                            "gte": 15,
                            "lte": 30,
                        }
                    }
                }
            ]
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
        size=1000
    )
    comments = res.body["hits"]["hits"]
    print(f"[Total Number of comments]: {len(comments)}")
    print(f"[Top Scored Comment in this range]: {comments[0]['_source']['body']}")
    print(f"[Lowest Scored Comment in this range]: {comments[-1]['_source']['body']}")


def query7(es):
    """
    Display the number of comments for every subreddit and the top comment score. Order them in popularity.
    :param es: Elastic Search API
    """
    indices = list(es.indices.get_alias().keys())
    aggs = {
        "numberOfCommentsPerSubreddit": {
            "terms": {
                "field": "subreddit.keyword",
                "size": 1000
            },
            "aggs": {
                "max_value": {
                    "max": {
                        "field": "score",
                    }
                }
            }
        }
    }

    res = es.search(
        index=indices,
        aggs=aggs,
        size=1000
    )
    results = res.body['aggregations']['numberOfCommentsPerSubreddit']['buckets']
    for result in results:
        subreddit = result['key']
        total_comments = result['doc_count']
        max_comment_score = result['max_value']['value']
        print(f"[subreddit]: {subreddit}, [total_comments]: {total_comments}, [top_comment_score]: {max_comment_score}")


def query8(es):
    """
    Query every comment between September 2007 and December 2007
    that either has the word ‘sql’ or ‘nosql’ in the comment.
    Only include comments which have a score greater than 0.
    Print the number of comments and print the first 10 results (sorted by score).
    :param es: Elastic Search API
    """
    indices = ['rc_2007-09', 'rc_2007-10', 'rc_2007-11', 'rc_2007-12']
    query = {
        "bool": {
            "must": [
                {
                    "bool": {
                        "should": [
                            {"term": {"body": "sql"}},
                            {"term": {"body": "nosql"}},
                        ]
                    }
                },
                {
                    "range": {
                        "score": {
                            "gte": 1,
                        }
                    }
                }
            ]
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
        size=1000
    )
    results = res.body['hits']['hits']
    print(f"total of {len(results)} were comments that either included sql or nosql")
    print(f"printing first 10 results:")

    for result in results[:11]:
        data = result['_source']
        print(f"\n[Author]: {data['author']}\n[Subreddit]: {data['subreddit']}"
              f"\n[Score]: {data['score']}\n[Comment]: {data['body']}")


def query9(es):
    """
    Find the top comment in January 2007, print it and also display the number of replies this comment got in total.
    :param es: Elastic Search API
    """
    indices = ['rc_2007-01']
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
        size=1
    )
    top_comment = res.body['hits']['hits'][0]['_source']
    print(top_comment)

    indices = list(es.indices.get_alias().keys())

    query = {
        "regexp": {"parent_id": f".*{top_comment['id']}*"}
    }

    sort = [
        {
            "created_utc": {
                "unmapped_type": "keyword",
                "order": "desc"
            }
        }
    ]

    res = es.search(
        index=indices,
        query=query,
        sort=sort,
        size=1000
    )

    replies = res.body['hits']['hits']
    print(f"Total Replies: {len(replies)}")


def query10(es):
    """
    Find all comments that mention at least 2 of the following words: sql, database and programming, software. In 2006. State the number of comments
    :param es: Elastic Search API
    """
    indices: list[str] = list(es.indices.get_alias().keys())
    for index in indices[:]:
        if index.find("2007") != -1:
            indices.remove(index)
    query = {
        "bool": {
            "should": [
                {
                    "term": {
                        "body": "sql"
                    }
                },
                {
                    "term": {
                        "body": "database"
                    }
                },
                {
                    "term": {
                        "body": "programming"
                    }
                },
                {
                    "term": {
                        "body": "software"
                    }
                }
            ],
            "minimum_should_match": 2
        }
    }

    res = es.search(
        index=indices,
        query=query,
        scroll='5m',
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

        data = es.scroll(scroll_id=sid, scroll='5m')

        # Update the scroll ID
        sid = data['_scroll_id']

        # Get the number of results that returned to the last scroll
        scroll_size = len(data['hits']['hits'])

    total = len(comments)
    print(f"total comments that include at least of of the following words: "
          f"sql, database, programming, software: {total}")


if __name__ == '__main__':
    main()
