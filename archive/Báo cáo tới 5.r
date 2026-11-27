# =====================================================================
# CÀI ĐẶT & NẠP THƯ VIỆN
# =====================================================================
install.packages(c("dplyr", "tidyr", "questionr", "e1071", "ggplot2", "ggcorrplot", "patchwork","writexl"))
library(dplyr)
library(tidyr)
library(e1071)
library(ggplot2)
library(ggcorrplot)
library(patchwork)

# =====================================================================
# PHẦN 4: TIỀN XỬ LÝ SỐ LIỆU (CHUẨN HÓA 1 OZ & LỌC MẪU - N = 76)
# =====================================================================

# 4.1. Đọc dữ liệu gốc và chuyển mã ẩn -1 thành NA
cereal_raw <- read.csv("D:/cereal.csv", stringsAsFactors = FALSE)
cereal_clean <- cereal_raw

num_cols <- c("calories", "protein", "fat", "sodium", "fiber",
              "carbo", "sugars", "potass", "weight", "cups", "rating")
cereal_clean[num_cols] <- lapply(cereal_clean[num_cols], function(x) {
  ifelse(x == -1, NA, as.numeric(x))
})

# 4.2. Lọc bỏ hãng A (n = 1) trước để tránh rò rỉ dữ liệu, lưu lại tên sản phẩm để tra cứu ngoại lai
cereal_filtered <- subset(cereal_clean, mfr != "A")
product_names <- cereal_filtered$name
cereal_filtered <- cereal_filtered[, !(names(cereal_filtered) %in% c("name", "type"))]

# 4.3. Điền giá trị khuyết (NA) bằng Trung vị (Median) tính trực tiếp trên tập mẫu N = 76
for (col in c("carbo", "sugars", "potass")) {
  med_val <- median(cereal_filtered[[col]], na.rm = TRUE)
  cereal_filtered[[col]][is.na(cereal_filtered[[col]])] <- med_val
}

# 4.4. Chuẩn hóa 8 biến dinh dưỡng về khẩu phần 1 oz, tạo biến total_carbs và bỏ weight, cups
nutri_cols <- c("calories", "protein", "fat", "sodium", "fiber", "carbo", "sugars", "potass")
for (col in nutri_cols) {
  cereal_filtered[[col]] <- cereal_filtered[[col]] / cereal_filtered$weight
}
cereal_filtered$total_carbs <- cereal_filtered$carbo + cereal_filtered$sugars

cereal_final <- cereal_filtered[, !(names(cereal_filtered) %in% c("weight", "cups"))]

# 4.5. Định dạng biến Factor có nhãn rõ ràng cho mfr và shelf (giữ nguyên vitamins dạng số nguyên)
mfr_labels <- c("G" = "General Mills", "K" = "Kelloggs", "N" = "Nabisco",
                "P" = "Post", "Q" = "Quaker Oats", "R" = "Ralston Purina")
cereal_final$mfr <- factor(mfr_labels[cereal_final$mfr])

cereal_final$shelf <- factor(cereal_final$shelf,
                             levels = c(1, 2, 3),
                             labels = c("Ke 1 (Thap)", "Ke 2 (Vua)", "Ke 3 (Cao)"))

# Xuất dữ liệu đã làm sạch chuẩn xác (76 dòng x 13 cột)
write.csv(cereal_final, "D:/cereal_cleaned.csv", row.names = FALSE)


# =====================================================================
# PHẦN 5: THỐNG KÊ MÔ TẢ (EDA)
# =====================================================================

# --- MỤC 5.1.1: THỐNG KÊ BIẾN ĐỊNH TÍNH & RỜI RẠC (BẢNG 4) ---
make_freq_table <- function(vec, var_label) {
  freq <- table(vec)
  prop <- round(prop.table(freq) * 100, 2)
  data.frame(
    Bien = var_label,
    Phan_nhom = names(freq),
    Tan_so_nk = as.vector(freq),
    Ty_le_fk = as.vector(prop),
    row.names = NULL
  )
}

bang_4 <- rbind(
  make_freq_table(cereal_final$mfr, "Nha san xuat (mfr)"),
  make_freq_table(cereal_final$shelf, "Vi tri ke (shelf)"),
  make_freq_table(cereal_final$vitamins, "Ham luong vitamin (%)")
)
print(bang_4)


# --- MỤC 5.1.2: THỐNG KÊ CÁC BIẾN ĐỊNH LƯỢNG (BẢNG 5) ---
vars_11 <- c("rating", "calories", "protein", "fat", "sodium",
             "fiber", "carbo", "sugars", "potass", "total_carbs", "vitamins")

calc_stats <- function(x) {
  c(n        = length(na.omit(x)),
    Mean     = mean(x, na.rm = TRUE),
    SD       = sd(x, na.rm = TRUE),
    Min      = min(x, na.rm = TRUE),
    Q1       = as.numeric(quantile(x, 0.25, na.rm = TRUE)),
    Median   = median(x, na.rm = TRUE),
    Q3       = as.numeric(quantile(x, 0.75, na.rm = TRUE)),
    Max      = max(x, na.rm = TRUE),
    IQR      = IQR(x, na.rm = TRUE),
    Skewness = skewness(x, na.rm = TRUE, type = 2))
}

bang_5 <- as.data.frame(round(t(sapply(cereal_final[vars_11], calc_stats)), 2))
print(bang_5)


# --- MỤC 5.1.3: PHÁT HIỆN NGOẠI LAI THEO HÀNG RÀO TUKEY (BẢNG 6) ---
find_outliers <- function(x, var_name) {
  Q1 <- as.numeric(quantile(x, 0.25, na.rm = TRUE))
  Q3 <- as.numeric(quantile(x, 0.75, na.rm = TRUE))
  IQR_val <- Q3 - Q1
  L <- Q1 - 1.5 * IQR_val
  U <- Q3 + 1.5 * IQR_val
  
  idx <- which(x < L | x > U)
  if (length(idx) > 0) {
    ord <- order(x[idx])
    vals <- round(x[idx][ord], 2)
    prods <- product_names[idx][ord]
    return(data.frame(
      Bien = var_name,
      Can_duoi_L = round(L, 2),
      Can_tren_U = round(U, 2),
      So_luong = length(idx),
      Gia_tri_va_San_pham = paste0(vals, " (", prods, ")", collapse = "; "),
      row.names = NULL
    ))
  } else {
    return(NULL)
  }
}

bang_6_ngoai_lai <- do.call(rbind, lapply(vars_11, function(v) find_outliers(cereal_final[[v]], v)))
print(bang_6_ngoai_lai)


# --- MỤC 5.2.1: BIỂU ĐỒ PHÂN PHỐI HISTOGRAM + KDE (HÌNH 1) ---
vars_10 <- c("rating", "calories", "protein", "fat", "sodium",
             "fiber", "carbo", "sugars", "potass", "total_carbs")

df_long <- cereal_final %>%
  select(all_of(vars_10)) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
  mutate(variable = factor(variable, levels = vars_10))

df_ref <- df_long %>%
  group_by(variable) %>%
  summarise(
    Mean = mean(value, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    .groups = "drop"
  )

p_hist <- ggplot(df_long, aes(x = value)) +
  geom_histogram(aes(y = after_stat(density)), fill = "skyblue", color = "black", bins = 12, alpha = 0.7) +
  geom_density(color = "#023047", linewidth = 0.8) +
  geom_vline(data = df_ref, aes(xintercept = Mean), color = "red", linetype = "dashed", linewidth = 0.8) +
  geom_vline(data = df_ref, aes(xintercept = Median), color = "blue", linetype = "solid", linewidth = 0.8) +
  facet_wrap(~ variable, scales = "free", ncol = 4) +
  theme_minimal(base_size = 10) +
  theme(strip.text = element_text(face = "bold")) +
  labs(title = "Hình 1: Phân phối tần suất (Histogram + KDE) của 10 biến định lượng liên tục (N = 76)",
       x = NULL, y = "Mật độ")
hinh_1 <- p_hist
print(hinh_1)
ggsave("Hinh_1_Histogram_KDE.png", plot = p_hist, width = 10, height = 6, dpi = 300)


# --- MỤC 5.2.2: BIỂU ĐỒ HỘP ĐƠN BIẾN (HÌNH 2) ---
df_long_11 <- cereal_final %>%
  select(all_of(vars_11)) %>%
  pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
  mutate(variable = factor(variable, levels = vars_11))

p_box <- ggplot(df_long_11, aes(x = value, y = factor(1))) +
  geom_boxplot(fill = "skyblue", color = "black", outlier.colour = "red", outlier.size = 2.2) +
  facet_wrap(~ variable, scales = "free_x", ncol = 4) +
  theme_minimal(base_size = 10) +
  theme(axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        strip.text = element_text(face = "bold")) +
  labs(title = "Hình 2: Biểu đồ hộp (Boxplot) phát hiện giá trị ngoại lai theo hàng rào Tukey (N = 76)",
       x = NULL, y = NULL)
hinh_2 <- p_box
print(hinh_2)
ggsave("Hinh_2_Boxplot.png", plot = p_box, width = 10, height = 6, dpi = 300)


# --- MỤC 5.2.3: BIỂU ĐỒ HỘP PHÂN NHÓM THEO mfr VÀ shelf (BẢNG 7 & HÌNH 3) ---
summary_mfr <- cereal_final %>%
  group_by(mfr) %>%
  summarise(n = n(),
            Mean = round(mean(rating), 2),
            SD = round(sd(rating), 2),
            Median = round(median(rating), 2),
            IQR = round(IQR(rating), 2),
            .groups = "drop")

summary_shelf <- cereal_final %>%
  group_by(shelf) %>%
  summarise(n = n(),
            Mean = round(mean(rating), 2),
            SD = round(sd(rating), 2),
            Median = round(median(rating), 2),
            IQR = round(IQR(rating), 2),
            .groups = "drop")
bang_7a <- summary_mfr
bang_7b <- summary_shelf

print(bang_7a)
print(bang_7b)

plot_mfr <- ggplot(cereal_final, aes(x = mfr, y = rating, fill = mfr)) +
  geom_boxplot(outlier.colour = "red") +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3.5, fill = "white", color = "red") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5),
        axis.text.x = element_text(angle = 20, hjust = 1)) +
  labs(title = "(a) Phân phối điểm rating theo Nhà sản xuất",
       x = "Nhà sản xuất (mfr)", y = "Điểm đánh giá (rating)")

plot_shelf <- ggplot(cereal_final, aes(x = shelf, y = rating, fill = shelf)) +
  geom_boxplot(outlier.colour = "red") +
  stat_summary(fun = mean, geom = "point", shape = 23, size = 3.5, fill = "white", color = "red") +
  theme_minimal(base_size = 10) +
  theme(legend.position = "none",
        plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5)) +
  labs(title = "(b) Phân phối điểm rating theo Vị trí kệ",
       x = "Vị trí kệ trưng bày (shelf)", y = NULL)

hinh_3 <- (plot_mfr + plot_shelf) +
  plot_annotation(
    title = "Hình 3: So sánh phân phối điểm đánh giá (rating) theo Nhà sản xuất và Vị trí kệ (N = 76)",
    theme = theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 12))
  )

print(hinh_3)
ggsave("Hinh_3_GroupedBoxplot.png", plot = hinh_3, width = 10, height = 4.5, dpi = 300)


# --- MỤC 5.2.4: MA TRẬN TƯƠNG QUAN VÀ BIỂU ĐỒ PHÂN TÁN (HÌNH 4) ---
corr_matrix <- cor(cereal_final[vars_11], use = "complete.obs")

plot_heatmap <- ggcorrplot(corr_matrix, type = "lower", lab = TRUE, lab_size = 2.8,
                           colors = c("#2166ac", "white", "#b2182b"),
                           title = "(a) Ma trận tương quan Pearson (r)",
                           legend.title = "Hệ số r") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5))

draw_scatter_custom <- function(var_x, label_x, r_val, pt_fill, label_pos, top_title = NULL) {
  p <- ggplot(cereal_final, aes(x = .data[[var_x]], y = rating)) +
    geom_point(alpha = 0.75, fill = pt_fill, color = "black", shape = 21, size = 2.2) +
    geom_smooth(method = "lm", color = "#1a3a5c", fill = "grey70", alpha = 0.35) +
    theme_bw(base_size = 9.5) +
    theme(panel.grid.major = element_line(linetype = "dotted", color = "grey75"),
          panel.grid.minor = element_blank(),
          plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5)) +
    labs(title = top_title, x = label_x, y = "rating")
  
  if (label_pos == "topright") {
    p <- p + annotate("label", x = Inf, y = Inf, label = paste("r =", r_val),
                      hjust = 1.1, vjust = 1.4, size = 3.2, fontface = "bold")
  } else {
    p <- p + annotate("label", x = -Inf, y = Inf, label = paste("r =", r_val),
                      hjust = -0.1, vjust = 1.4, size = 3.2, fontface = "bold")
  }
  return(p)
}

p_sugars   <- draw_scatter_custom("sugars", "sugars (g/oz)", "-0.765", "#e41a1c", "topright",
                                  "(b) Tương quan tuyến tính của rating với 3 biến")
p_fiber    <- draw_scatter_custom("fiber", "fiber (g/oz)", "0.660", "#41b6c4", "topleft")
p_calories <- draw_scatter_custom("calories", "calories (kcal/oz)", "-0.648", "#fdae61", "topright")

plot_scatters <- p_sugars / p_fiber / p_calories

hinh_4 <- (plot_heatmap | plot_scatters) +
  plot_layout(widths = c(1.35, 1)) +
  plot_annotation(
    title = "Hình 4: Ma trận tương quan Pearson và Biểu đồ phân tán (Scatter Plot) của điểm đánh giá (N = 76)",
    theme = theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 12))
  )

print(hinh_4)
ggsave("Hinh_4_Correlation_Scatter_Dep.png", plot = hinh_4, width = 12, height = 7.5, dpi = 300)