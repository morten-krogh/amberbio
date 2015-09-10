#include "distributions.h"

double beta(double a, double b)
{
        /*
                Beta(a, b) = Gamme(a) * Gamma(b) / Gamma(a + b)
                a > 0, b > 0
         */

        double lgamma_a = lgamma(a);
        double lgamma_b = lgamma(b);
        double lgamma_ab = lgamma(a + b);

        return exp(lgamma_a + lgamma_b - lgamma_ab);
}

double incomplete_beta_continued_fraction(double a, double b, double x)
{
        double relative_error = 1e-10;

        double numerator = 1.0;
        double denominator = 1.0;
        double numerator_previous = 0.0;
        double denominator_previous = 1.0;

        for (int n = 1; n < 100; n++) {
                double d;

                if (n % 2 == 0) {
                        double m = n / 2;
                        d = (m * (b - m) * x) / ((a + 2 * m - 1) * (a + 2 * m));
                } else {
                        double m = (n - 1) / 2;
                        d = - ((a + m) * (a + b + m) * x) / ((a + 2 * m) * (a + 2 * m + 1));
                }

                double numerator_temp = numerator + d * numerator_previous;
                double denominator_temp = denominator + d * denominator_previous;

                numerator_previous = numerator;
                denominator_previous = denominator;
                numerator = numerator_temp;
                denominator = denominator_temp;

                double scale = numerator < denominator ? numerator : denominator;
                if (scale > 1) {
                        numerator /= scale;
                        denominator /= scale;
                        numerator_previous /= scale;
                        denominator_previous /= scale;
                }

                if (numerator != 0 && denominator != 0 && numerator_previous != 0 && denominator_previous != 0) {
                        double fraction = numerator / denominator;
                        double fraction_previous = numerator_previous / denominator_previous;
                        double ratio_of_fractions = fraction / fraction_previous;
                        if (n >= 3 && ratio_of_fractions > (1 - relative_error) && ratio_of_fractions < (1 + relative_error)) {
                                break;
                        }
                }
        }

        double fraction;
        if (denominator <= 1e-20 && denominator >= -1e-20) {
                fraction = numerator / denominator;
        } else {
                fraction = numerator_previous / denominator_previous;
        }

        return fraction;
}

double incomplete_beta(double a, double b, double x)
{
        double factor = exp(a * log(x) + b * log(1 - x) - lgamma(a) - lgamma(b) + lgamma(a + b));

        if (x < (a + 1) / (a + b + 2)) {
                return factor * incomplete_beta_continued_fraction(a, b, x) / a;
        } else {
                return 1 - factor * incomplete_beta_continued_fraction(b, a, 1 - x) / b;
        }
}

double f_distribution_upper_tail(long degrees_of_freedom_upper, long degrees_of_freedom_lower, double quantile)
{
        double a = degrees_of_freedom_lower / 2.0;
        double b = degrees_of_freedom_upper / 2.0;
        double x = degrees_of_freedom_lower / (degrees_of_freedom_upper * quantile + degrees_of_freedom_lower);

        return incomplete_beta(a, b, x);
}

double t_distribution_upper_tail(long degrees_of_freedom, double quantile)
{
        double a = degrees_of_freedom / 2.0;
        double b = 0.5;
        double x = degrees_of_freedom / (quantile * quantile + degrees_of_freedom);

        return 0.5 * incomplete_beta(a, b, x);
}


