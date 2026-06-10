; extends

; By default Vue directive names (v-if, v-for, v-show, v-model, ...) and plain
; static HTML attributes (class, id) both capture as @tag.attribute, so they
; share a color. Re-capture the directive name as a keyword so it reads
; distinctly from static attributes. Colored via @keyword.directive.vue.
(directive_name) @keyword.directive
