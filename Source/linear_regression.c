#include "c-functions.h"

void linear_regression(const double* x_values, const double* y_values, const long number_of_values,double* intercept, double* slope, double* p_value)
{
        if (number_of_values <= 1) {
                *intercept = nan(NULL);
                *slope = nan(NULL);
                *p_value = nan(NULL);
                return;
        }

        double s = number_of_values;
        double s_x = 0;
        double s_y = 0;
        double s_xx = 0;
        double s_xy = 0;
        double s_yy = 0;

        for (long i = 0; i < number_of_values; i++) {
                double x = x_values[i];
                double y = y_values[i];
                s_x += x;
                s_y += y;
                s_xx += x * x;
                s_xy += x * y;
                s_yy += y * y;
        }

        double ss_xx = s * s_xx - s_x * s_x;

        if (ss_xx == 0) {
                *intercept = s_y / s;
                *slope = nan(NULL);
                *p_value = nan(NULL);
                return;
        }

        double a = (s * s_xy - s_x * s_y) / ss_xx;
        double b = (s_y * s_xx - s_x * s_xy) / ss_xx;

        double mean_residuals = a * a * s_xx + b * b * s + 2 * a * b * s_x - s_y * s_y / s;
        double model_residuals = a * a * s_xx + b * b * s + 2 * a * b * s_x - 2 * a * s_xy - 2 * b * s_y + s_yy;

        long model_degrees_of_freedom = number_of_values - 2;

        double f_statistic = nan(NULL);
        double p = nan(NULL);

        if (model_residuals > 0) {
                f_statistic = mean_residuals * model_degrees_of_freedom / model_residuals;
                p = distribution_f_upper_tail(1, model_degrees_of_freedom, f_statistic);
        } else if (model_degrees_of_freedom > 0 && mean_residuals > 0) {
                p = 0;
        }

        *slope = a;
        *intercept = b;
        *p_value = p;
}
