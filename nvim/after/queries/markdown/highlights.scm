; after/queries/markdown/highlights.scm
; extends

; Checked task items: the checkbox marker is already captured by the stock
; query; capture the item text too, so it shares @markup.list.checked with
; the checkbox and colorschemes can gray both out.
(list_item
  (task_list_marker_checked)
  (paragraph) @markup.list.checked)
