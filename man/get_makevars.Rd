% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/generate.R
\name{get_makevars}
\alias{get_makevars}
\title{Determine Path to Makevars File and Check if it Already Exists}
\usage{
get_makevars(path = ".")
}
\arguments{
\item{path}{The path of the package}
}
\value{
A list containing
\item{path}{The absolute path to the Makevars file}
\item{exists}{Whether or not the Makevars file currently exists}
}
\description{
Determine Path to Makevars File and Check if it Already Exists
}
