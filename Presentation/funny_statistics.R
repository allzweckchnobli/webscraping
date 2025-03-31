library(readxl)
library(dplyr)
library(stringr)
library(ggplot2)
library(stringr)

youtubedata <- read_xlsx("youtubedata.xlsx")
youtubedata$views_numeric <- as.numeric(youtubedata$views_numeric)
youtubedata$duration_numeric <- as.numeric(youtubedata$hours)*3600+as.numeric(youtubedata$minutes)*60+as.numeric(youtubedata$seconds)

youtubedata <- youtubedata %>%
  mutate(
    timeaxis = case_when(
      str_detect(date_word, "year")  ~ as.numeric(date_numeric) * 365, 
      str_detect(date_word, "month") ~ as.numeric(date_numeric) * 30, 
      str_detect(date_word, "week")  ~ as.numeric(date_numeric) * 7, 
      str_detect(date_word, "day")   ~ as.numeric(date_numeric), 
      TRUE ~ NA_real_  # Default case to handle unexpected values
    )
  )

ggplot(youtubedata, aes(x = timeaxis, y = duration_numeric)) +
  geom_point(alpha = 0.6, color = "blue") +  # Scatter plot with transparency
  labs(
    title = "Time Axis vs Duration",
    x = "Time Axis (in days ago)",
    y = "Duration (in seconds)"
  ) +
  theme_minimal()

youtubedata$month_timeaxis <- floor(youtubedata$timeaxis / 365)
youtubedata$year_timeaxis <- 2025-youtubedata$month_timeaxis

ggplot(youtubedata, aes(x = year_timeaxis)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "black", alpha = 0.7) +
  labs(
    title = "Amounts of videos uploaded per year",
    x = "Year",
    y = "Amount of Videos uploaded"
  ) +
  theme_minimal()


# Beautifulsoup -----------------------------------------------------------

scraped <- read_xlsx("scraped.xlsx")

emoji_pattern <- "[\U0001F300-\U0001F6FF\U0001F900-\U0001F9FF\U0001F000-\U0001F02F]"

scraped_with_emojis <- scraped %>%
  filter(str_detect(Description, emoji_pattern))


