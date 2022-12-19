library(RcensusUK)

yk <- lookups[, .(OA, MSOA)] |> setkey('OA')
y <- dt_sexage[var_id %in% c(8002, 8003, 7002, 7020, 7021, 7026, 7070:7075, 7086, 7097, 9123, 9124, 9129, 9135, 9146)]

# total population: dt_population >> 1001
y1 <- dt_population[var_id == 1001, .(OA = zone_id, value)][yk, on = 'OA'][, .(population = sum(value, na.rm = TRUE)), MSOA] |> setkey('MSOA')

# males: dt_sexage >> 8003
y2 <- y[var_id == 8003, .(OA = zone_id, value)][yk, on = 'OA'][, .(males = sum(value, na.rm = TRUE)), MSOA] |> setkey('MSOA')

# females: dt_sexage >> 8002
y3 <- y[var_id == 8002, .(OA = zone_id, value)][yk, on = 'OA'][, .(females = sum(value, na.rm = TRUE)), MSOA] |> setkey('MSOA')

# children 0-4: dt_sexage >> 7002
y4 <- y[var_id == 7002, .(MSOA = zone_id, children = value)] |> setkey('MSOA')

# youth 15-24: dt_sexage >> 7020, 7021, 7026
y5 <- y[var_id %in% c(7020, 7021, 7026), .(youth = sum(value)), .(MSOA = zone_id)] |> setkey('MSOA')

# elderly 60+: dt_sexage >> 7070:7075, 7086, 7097
y6 <- y[var_id %in% c(7070:7075, 7086, 7097), .(elderly = sum(value)), .(MSOA = zone_id)] |> setkey('MSOA')


fwrite(y1[y2[y3[y4[y5[y6]]]]], './data-raw/csv/census.csv')
