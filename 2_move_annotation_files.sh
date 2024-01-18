mycocosm=$(pwd)/mycocosm_annotations

if [ ! -d "$mycocosm" ]; then
  echo "Creating mycocosm_annotations directory."
  mkdir mycocosm_annotations
fi

mv $1/*/Annotation/Mycocosm/Annotation/Filtered_Models___best__/Functional_Annotations/GO/* ${mycocosm}

rm -rf $1