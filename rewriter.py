import re

def general(key, value, lines, modifier):
    regex = re.compile('((.*)(%s)[+]?=)(.*)' % key)
    for line in lines:
        match = regex.match(line)
        if match is None:
            yield line
        else:
            for m in modifier(match, key, value):
                yield m

def rewrite(match, key, value):
    yield '%s%s' %(match.group(1), value)

def add(match, key, value):
    yield match.group(0)
    yield '%s+=%s' %(key, value)

def edit_with(file_name, key, value, editor):
    with open(file_name) as lines:
        new = list(editor(key, value, (l.strip() for l in lines)))
    with open(file_name, 'w') as file:
        for l in new:
            print >> file, l

if __name__ == '__main__':
    from argparse import ArgumentParser

    parser = ArgumentParser()
    parser.add_argument('file', help='file to edit')

    parser.add_argument('-r', '--rewrite', default=False, action='store_true')
    parser.add_argument('-a', '--add', default=False, action='store_true')
    parser.add_argument('-k', '--key')
    parser.add_argument('-v', '--value')

    args = parser.parse_args()

    if args.rewrite and args.add:
        print 'noo %s %s' % (args.rewrite, args.add)
        raise Exception

    if args.rewrite:
        edit_with(args.file, args.key, args.value, lambda k, v, ls: general(k, v, ls, rewrite))
    elif args.add:
        edit_with(args.file, args.key, args.value, lambda k, v, ls: general(k, v, ls, add))
    else:
        raise