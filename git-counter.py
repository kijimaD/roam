#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""gitのコードの増加をグラフ化する
https://gist.github.com/TakesxiSximada/fddd6df72b5762ebcd39
"""
import six

import os
import sys
import json
import argparse
import datetime
import tempfile
import subprocess

import numpy as np
import pandas as pd
from bokeh.plotting import (
    show,
    figure,
    output_file,
    )

if six.PY3:
    import io
else:
    import StringIO as io  # noqa

DT_FMT = '%Y-%m-%d'
ADD_LINE_FMT = """git log --since={} --until={} --oneline --numstat --no-merges --pretty=format:"" | egrep "{}" | cut -f1 | awk 'BEGIN {{sum=0}} {{sum+=$1}} END {{print sum}}'"""  # noqa
DEL_LINE_FMT = """git log --since={} --until={} --oneline --numstat --no-merges --pretty=format:"" | egrep "{}" | cut -f2 | awk 'BEGIN {{sum=0}} {{sum+=$1}} END {{print sum}}'"""  # noqa


def execute(line, type_=int):
    stdout = tempfile.TemporaryFile()
    child = subprocess.Popen(line, shell=True, stdout=stdout)
    child.wait()
    stdout.seek(0)
    line = stdout.read()
    data = line.strip()
    return type_(data) if type_ else data


def calc_add_and_del(start, end, pattern):
    add_line_cmd = ADD_LINE_FMT.format(start, end, pattern)
    del_line_cmd = DEL_LINE_FMT.format(start, end, pattern)
    add_count = execute(add_line_cmd)
    del_count = execute(del_line_cmd)
    return add_count, del_count


def create_cache_data(start, end, pattern):
    a_day_ago = datetime.timedelta(days=1)
    start_dt = datetime.datetime.strptime(start, DT_FMT)
    end_dt = datetime.datetime.strptime(end, DT_FMT)

    date_add_del = []
    for year in range(start_dt.year, end_dt.year+1):
        for month in range(1, 12+1):
            if (start_dt.year == year and month < start_dt.month) or (end_dt.year == year and month > end_dt.month):
                continue
            _start_dt = datetime.date(year, month, 1)
            _end_dt = (datetime.date(year, month + 1, 1) if month != 12 else datetime.date(year+1, 1, 1)) - a_day_ago
            add_count, del_count = calc_add_and_del(_start_dt.strftime(DT_FMT), _end_dt.strftime(DT_FMT), pattern)
            date_add_del.append([_start_dt.strftime(DT_FMT), add_count, del_count])
    return json.dumps(date_add_del)


def export(data, output):
    data = json.loads(data)
    output_file(output, title="git graph")
    TOOLS = "pan,wheel_zoom,box_zoom,reset,save"
    df = pd.DataFrame(data)
    columns = [datetime.datetime.strptime(stamp, '%Y-%m-%d') for stamp in df[0][1:]]
    c = figure(tools=TOOLS, x_axis_type="datetime")
    c.line(columns, np.array(df[1][1:], dtype=int), color='#DF0101', legend='add')
    c.line(columns, np.array(df[2][1:], dtype=int), color='#2E2EFE', legend='delete')
    c.line(columns, np.cumsum(df[1][1:] - df[2][1:]), color='#64FE2E', legend='total')
    show(c)


def main(argv=sys.argv[1:]):
    today = datetime.date.today()
    one_day_ago = datetime.timedelta(days=1)
    last_month = datetime.date(today.year, today.month, 1) - one_day_ago
    last_year = datetime.date(last_month.year-1, last_month.month, 1)

    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--start', default=last_year.strftime(DT_FMT))
    parser.add_argument('-e', '--end', default=last_month.strftime(DT_FMT))
    parser.add_argument('-c', '--cache', default='cache.json')
    parser.add_argument('--no-cache', default=False, action='store_true')
    parser.add_argument('-p', '--pattern', default='.org$')
    parser.add_argument('-o', '--output', default='./public/line.html')
    args = parser.parse_args(argv)

    cache_data = None
    if not os.path.exists(args.cache):
        cache_data = create_cache_data(args.start, args.end, args.pattern)
    else:
        with open(args.cache, 'rt') as fp:
            cache_data = json.load(fp)

    if not args.no_cache:
        with open(args.cache, 'w+t') as fp:
            json.dump(cache_data, fp)

    export(cache_data, args.output)
    print('exported: {}'.format(args.output))

if __name__ == '__main__':
    sys.exit(main())
