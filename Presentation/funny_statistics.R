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
  geom_point(alpha = 0.6, color = "#4AC9E3") +  # Scatter plot with transparency
  labs(
    title = "Time Axis vs Duration",
    x = "Time Axis (in days ago)",
    y = "Duration (in seconds)"
  ) +
  theme_minimal()
ggsave("durationacrosstime.svg",height=6,width=9)

youtubedata$month_timeaxis <- floor(youtubedata$timeaxis / 365)
youtubedata$year_timeaxis <- 2025-youtubedata$month_timeaxis

ggplot(youtubedata, aes(x = year_timeaxis)) +
  geom_histogram(binwidth = 1, fill = "#7596FF", color = "#001E7C", alpha = 1) +
  labs(
    title = "Amounts of videos uploaded per year",
    x = "Year",
    y = "Amount of Videos uploaded"
  ) +
  theme_minimal()
ggsave("videosuploaded.svg",height=6,width=9)

# Beautifulsoup -----------------------------------------------------------

scraped <- read_xlsx("scraped.xlsx")

emoji_pattern <- "[\U0001F300-\U0001F6FF\U0001F900-\U0001F9FF\U0001F000-\U0001F02F]"

scraped_with_emojis <- scraped %>%
  filter(str_detect(Description, emoji_pattern))

descriptions <- scraped %>% select(Description)
write.table(descriptions,"descriptions.txt")

scraped <- scraped %>% filter(
  !is.na(Link)
) %>% mutate(
    title = case_when(
      str_detect(Name, "Prof") ~ "Prof.", 
      TRUE ~ "Dr."
    )
  ) %>% mutate(
    position = case_when(
      str_detect(tolower(Title...6), "snf") ~ "SNF Professor",
      str_detect(tolower(Title...6), "ord") ~"Ordinarius / Ordinaria",
      str_detect(tolower(Title...6), "assist") ~ "Assistant Professor",
      TRUE ~ "Other"
    )
  )

## length 
scraped$length_desc <- nchar(scraped$Description)

scraped <- scraped %>% arrange(desc(length_desc))
ggplot(scraped, aes(x = reorder(Subtitle, -length_desc), y = length_desc)) +
  geom_point(color = "#0028A5", size = 3) +   # Plot point
  labs(x = "Subtitle", y = "Length (words)", title = "Length of Description by Department") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggsave("lengthdesc.svg",height=6,width=9)

plot(scraped$position)
