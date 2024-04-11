## Based on the Quarto Dashboard for Earthquakes available here:
## https://raw.githubusercontent.com/cwickham/quakes/main/quakes.qmd

---
title: Recent Earthquakes in Aotearoa New Zealand
author: Of Weak Intensity or Greater
format: 
  dashboard:
    orientation: columns
    theme: yeti
---

```{r}
#| message: false
library(tidyverse)
library(httr2)
library(sf)
library(leaflet)
library(gt)
```

```{r}
# Get data from GeoNet
# MMI = 3, weak or above
req <- request("https://api.geonet.org.nz/quake?MMI=3") |> 
  req_headers("Accept"="application/vnd.geo+json")
resp <- req_perform(req)
recent_quakes <- resp |> 
  resp_body_string() |> 
  st_read(quiet = TRUE)
```

```{r}
# Prettier times and dates
recent_quakes <- recent_quakes |> 
  arrange(desc(time)) |> 
  mutate(
    time = force_tz(time, "Pacific/Auckland"),
    pretty_time = format(time, "%I:%M %p"),
    days_ago = today(tzone = "Pacific/Auckland") - date(time),
    days_ago = case_when(
      days_ago == 0 ~ "Today",
      days_ago == 1 ~ "Yesterday",
      TRUE ~ paste0(days_ago, " days ago")
    )
  )
now_nz <- now(tzone = "Pacific/Auckland")
last_24 <- recent_quakes |> filter(time > (now_nz - hours(24)))
n_24 <- nrow(last_24)
hours_last <- round(difftime(now_nz, recent_quakes$time[1], units = "hours"))
```

```{r}
mag_pal <- colorBin("inferno", domain = 1:8, bins = c(0:5, 8))

quake_map <- recent_quakes |> 
  leaflet() |> 
  addCircleMarkers(
    color = ~ mag_pal(magnitude),
    stroke = FALSE,
    fillOpacity = 0.5,
    radius = ~ scales::rescale(sqrt(magnitude), c(1, 10)),
    label = ~ paste(
      date(time), pretty_time, "<br/>",
      "Magnitude:", round(magnitude, 1), "<br/>", 
      "Depth:",  round(depth), " km"
      ) |> map(html),
    labelOptions = c(textsize = "15px")) |> 
  addLegend(title = "Magnitude", colors = mag_pal(0:5), labels = c("<1", 1:4,">5")) |> 
  addTiles("http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}", options = tileOptions(minZoom = 5, maxZoom = 10)) 
```

```{r}
mag_hist <- recent_quakes |> 
  ggplot(aes(x = magnitude)) +
  geom_histogram()
```

```{r}
timeline <- recent_quakes |> 
  ggplot(aes(x = time, y = 0)) +
  geom_point()
```


```{r}
# Create n most recent table
n <- 10
top_n <- recent_quakes |> 
  slice(1:n) |> 
  as.data.frame() |> 
  select(magnitude, days_ago, pretty_time, locality, depth) 

top_n_table <- top_n |> 
  gt() |> 
  cols_label(
    days_ago = "",
    locality = "Location",
    magnitude = "Magnitude",
    depth = "Depth",
    pretty_time = ""
  ) |> 
  fmt_integer(
    columns = depth, 
    pattern = "{x} km"
  ) |> 
  fmt_number(
    columns = magnitude,
    decimals = 1
  ) |> 
  data_color(
    columns = "magnitude",
    fn = mag_pal
  ) |>
  tab_header(
    title = md("**Last 10 Earthquakes**")
  ) |> 
  tab_source_note(
    source_note = md(paste("Retrieved from the [GeoNet API](https://api.geonet.org.nz/) at", format(now_nz, "%Y/%m/%d %H:%M %Z")))
  )
```

## Column

### Row 

```{r}
#| component: valuebox
#| title: Hours since last earthquake
list(
  icon = "stopwatch",
  color = "primary",
  value = as.numeric(hours_last)
)
```

```{r}
#| component: valuebox
#| title: Earthquakes in the last 24 hours
list(
  icon = "activity",
  color = "secondary",
  value = n_24
)
```

### Row

```{r}
top_n_table
```


## Column

```{r}
#| title: 100 Most Recent Earthquakes
quake_map
```
