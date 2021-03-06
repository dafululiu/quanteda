#' extract a subset of a corpus
#' 
#' Returns subsets of a corpus that meet certain conditions, including direct 
#' logical operations on docvars (document-level variables).  \code{corpus_subset}
#' functions identically to \code{\link{subset.data.frame}}, using non-standard
#' evaluation to evaluate conditions based on the \link{docvars} in the corpus.
#' 
#' @param x \link{corpus} object to be subsetted
#' @param subset logical expression indicating the documents to keep: missing
#'   values are taken as false
#' @param select expression, indicating the docvars to select from the corpus
#' @param ... not used
#' @return corpus object, with a subset of documents (and docvars) selected according to arguments
#' @export
#' @seealso \code{\link{subset.data.frame}}
#' @keywords corpus
#' @examples
#' summary(corpus_subset(data_corpus_inaugural, Year > 1980))
#' summary(corpus_subset(data_corpus_inaugural, Year > 1930 & President == "Roosevelt", 
#'                       select = Year))
corpus_subset <- function(x, subset, select, ...) {
    UseMethod("corpus_subset")
}
    
#' @export
corpus_subset.default <- function(x, subset, select, ...) {
    stop(friendly_class_undefined_message(class(x), "corpus_subset"))
}

#' @export
corpus_subset.corpus <- function(x, subset, select, ...) {
    
    if (length(addedArgs <- list(...)))
        warning("Argument", if (length(addedArgs) > 1L) "s " else " ", names(addedArgs), " not used.", sep = "")
    r <- if (missing(subset)) {
        rep_len(TRUE, nrow(documents(x)))
    } else {
        e <- substitute(subset)
        r <- eval(e, documents(x), parent.frame())
        r & !is.na(r)
    }
    vars <- if (missing(select)) 
        TRUE
    else {
        nl <- as.list(seq_along(documents(x)))
        names(nl) <- names(documents(x))
        c(1, eval(substitute(select), nl, parent.frame()))
    }
    
    documents(x) <- documents(x)[r, vars, drop = FALSE]
    if (is.corpuszip(x)) {
        texts(x) <- texts(x)[r]
        x$docnames <- rownames(documents(x))
    }
    
    x
}

