merge_objs = (o1, o2) ->
    for k, v of o2
        o1[k] = v
    return o1

merge_all = (objs) ->
    oa = {}
    for o in objs
        merge_objs oa, o
    return oa

module.exports = {
    merge_objs
    merge_all
}
