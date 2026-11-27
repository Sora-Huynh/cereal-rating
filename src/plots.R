# =====================================================================
# src/plots.R
# Các hàm vẽ Hình 1 – 4 của Phần 5 và hàm lưu hình.
# Script gọi các hàm này: analysis/03_descriptive_plots.R
# Cần source("src/config.R") trước.
# =====================================================================

# Lưu hình ra results/figures/
save_figure <- function(plot, filename, width, height) {
  dir.create(paths$figures_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(paths$figures_dir, filename)
  ggsave(path, plot = plot, width = width, height = height, dpi = fig_dpi)
  cat("  -> đã lưu", path, "\n")
  invisible(path)
}

# Chỉ hiện hình khi chạy tương tác (RStudio). Khi chạy bằng Rscript, print()
# sẽ vẽ vào Rplots.pdf và báo lỗi font tiếng Việt, nên bỏ qua.
show_plot <- function(p) {
  if (interactive()) print(p)
  invisible(p)
}

# Chuyển các cột vars sang dạng dài (variable, value), giữ thứ tự biến
to_long <- function(df, vars) {
  df %>%
    select(all_of(vars)) %>%
    pivot_longer(cols = everything(), names_to = "variable", values_to = "value") %>%
    mutate(variable = factor(variable, levels = vars))
}

# --- Hình 1 (mục 5.2.1): Histogram + KDE, nét đứt đỏ = trung bình, nét liền xanh = trung vị
plot_hist_kde <- function(df, vars) {
  df_long <- to_long(df, vars)
  df_ref <- df_long %>%
    group_by(variable) %>%
    summarise(Mean = mean(value, na.rm = TRUE),
              Median = median(value, na.rm = TRUE),
              .groups = "drop")

  ggplot(df_long, aes(x = value)) +
    geom_histogram(aes(y = after_stat(density)), fill = "skyblue", color = "black",
                   bins = 12, alpha = 0.7) +
    geom_density(color = "#023047", linewidth = 0.8) +
    geom_vline(data = df_ref, aes(xintercept = Mean),
               color = "red", linetype = "dashed", linewidth = 0.8) +
    geom_vline(data = df_ref, aes(xintercept = Median),
               color = "blue", linetype = "solid", linewidth = 0.8) +
    facet_wrap(~ variable, scales = "free", ncol = 4) +
    theme_minimal(base_size = 10) +
    theme(strip.text = element_text(face = "bold")) +
    labs(title = sprintf("Hình 1: Phân phối tần suất (Histogram + KDE) của %d biến định lượng liên tục (N = %d)",
                         length(vars), nrow(df)),
         x = NULL, y = "Mật độ")
}

# --- Hình 2 (mục 5.2.2): Boxplot đơn biến, điểm đỏ = ngoại lai theo hàng rào Tukey
plot_box_univariate <- function(df, vars) {
  ggplot(to_long(df, vars), aes(x = value, y = factor(1))) +
    geom_boxplot(fill = "skyblue", color = "black", outlier.colour = "red", outlier.size = 2.2) +
    facet_wrap(~ variable, scales = "free_x", ncol = 4) +
    theme_minimal(base_size = 10) +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid.major.y = element_blank(),
          strip.text = element_text(face = "bold")) +
    labs(title = sprintf("Hình 2: Biểu đồ hộp (Boxplot) phát hiện giá trị ngoại lai theo hàng rào Tukey (N = %d)",
                         nrow(df)),
         x = NULL, y = NULL)
}

# --- Hình 3 (mục 5.2.3): Boxplot rating theo mfr và theo shelf, hình thoi trắng = trung bình
plot_rating_by_group <- function(df) {
  plot_mfr <- ggplot(df, aes(x = mfr, y = rating, fill = mfr)) +
    geom_boxplot(outlier.colour = "red") +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 3.5, fill = "white", color = "red") +
    theme_minimal(base_size = 10) +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5),
          axis.text.x = element_text(angle = 20, hjust = 1)) +
    labs(title = "(a) Phân phối điểm rating theo Nhà sản xuất",
         x = "Nhà sản xuất (mfr)", y = "Điểm đánh giá (rating)")

  plot_shelf <- ggplot(df, aes(x = shelf, y = rating, fill = shelf)) +
    geom_boxplot(outlier.colour = "red") +
    stat_summary(fun = mean, geom = "point", shape = 23, size = 3.5, fill = "white", color = "red") +
    theme_minimal(base_size = 10) +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5)) +
    labs(title = "(b) Phân phối điểm rating theo Vị trí kệ",
         x = "Vị trí kệ trưng bày (shelf)", y = NULL)

  (plot_mfr + plot_shelf) +
    plot_annotation(
      title = sprintf("Hình 3: So sánh phân phối điểm đánh giá (rating) theo Nhà sản xuất và Vị trí kệ (N = %d)",
                      nrow(df)),
      theme = theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 12))
    )
}

# Biểu đồ phân tán rating theo một biến, có đường hồi quy và nhãn hệ số r
draw_scatter_custom <- function(df, var_x, label_x, r_val, pt_fill, label_pos,
                                top_title = NULL) {
  p <- ggplot(df, aes(x = .data[[var_x]], y = rating)) +
    geom_point(alpha = 0.75, fill = pt_fill, color = "black", shape = 21, size = 2.2) +
    geom_smooth(method = "lm", formula = y ~ x, color = "#1a3a5c", fill = "grey70", alpha = 0.35) +
    theme_bw(base_size = 9.5) +
    theme(panel.grid.major = element_line(linetype = "dotted", color = "grey75"),
          panel.grid.minor = element_blank(),
          plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5)) +
    labs(title = top_title, x = label_x, y = "rating")

  if (label_pos == "topright") {
    p + annotate("label", x = Inf, y = Inf, label = paste("r =", r_val),
                 hjust = 1.1, vjust = 1.4, size = 3.2, fontface = "bold")
  } else {
    p + annotate("label", x = -Inf, y = Inf, label = paste("r =", r_val),
                 hjust = -0.1, vjust = 1.4, size = 3.2, fontface = "bold")
  }
}

# --- Hình 4 (mục 5.2.4): (a) heatmap ma trận tương quan Pearson,
# (b) phân tán rating theo sugars, fiber, calories. Hệ số r lấy từ corr_matrix.
plot_corr_scatter <- function(df, corr_matrix) {
  r_of <- function(v) sprintf("%.3f", corr_matrix["rating", v])

  plot_heatmap <- ggcorrplot(corr_matrix, type = "lower", lab = TRUE, lab_size = 2.8,
                             colors = c("#2166ac", "white", "#b2182b"),
                             title = "(a) Ma trận tương quan Pearson (r)",
                             legend.title = "Hệ số r") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5))

  p_sugars   <- draw_scatter_custom(df, "sugars", "sugars (g/oz)", r_of("sugars"),
                                    "#e41a1c", "topright",
                                    "(b) Tương quan tuyến tính của rating với 3 biến")
  p_fiber    <- draw_scatter_custom(df, "fiber", "fiber (g/oz)", r_of("fiber"),
                                    "#41b6c4", "topleft")
  p_calories <- draw_scatter_custom(df, "calories", "calories (kcal/oz)", r_of("calories"),
                                    "#fdae61", "topright")

  (plot_heatmap | (p_sugars / p_fiber / p_calories)) +
    plot_layout(widths = c(1.35, 1)) +
    plot_annotation(
      title = sprintf("Hình 4: Ma trận tương quan Pearson và Biểu đồ phân tán (Scatter Plot) của điểm đánh giá (N = %d)",
                      nrow(df)),
      theme = theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 12))
    )
}
